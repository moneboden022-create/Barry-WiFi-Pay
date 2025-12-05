from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from datetime import datetime

from ..db import get_db
from ..security import get_current_user
from ..models import WifiAccess, ConnectionHistory
from ..utils import (
    get_active_subscription,
    get_or_create_device,
    count_user_devices,
    log_connection_history,
    close_connection_history,
    cleanup_old_devices,
)
from ..services.network.providers import WifiNetworkManager

router = APIRouter(prefix="/wifi", tags=["Wi-Fi Control"])
wifi_manager = WifiNetworkManager()


# ============================================================
# 🔥 ACTIVER INTERNET
# ============================================================
@router.post("/activate")
def activate_wifi(request: Request, db: Session = Depends(get_db), user=Depends(get_current_user)):
    now = datetime.utcnow()

    # 1️⃣ Vérifier forfait actif
    subscription = get_active_subscription(db, user.id)
    if not subscription:
        raise HTTPException(403, "Aucun forfait actif.")

    # 2️⃣ Device ID obligatoire
    device_id = request.headers.get("X-Device-ID")
    if not device_id:
        raise HTTPException(400, "X-Device-ID manquant.")

    ua = request.headers.get("User-Agent", "Unknown")
    ip = request.client.host if request.client else None

    # 3️⃣ Limite appareils
    # fallback valeur par défaut si user.max_devices_allowed existe pas
    max_devices_allowed = getattr(user, "max_devices_allowed", 1)
    total_devices = count_user_devices(db, user.id)

    if total_devices >= max_devices_allowed:
        cleanup_old_devices(db, user.id, max_devices_allowed)
        total_devices = count_user_devices(db, user.id)

        if total_devices >= max_devices_allowed:
            raise HTTPException(403, f"Limite d'appareils atteinte ({max_devices_allowed}).")

    # 4️⃣ Créer ou mettre à jour le device
    device = get_or_create_device(db, user.id, device_id, ip, ua)

    # 5️⃣ Activation réseau via provider
    ok, msg = wifi_manager.activate_wifi(user.id)
    if not ok:
        raise HTTPException(500, f"Impossible d'activer le réseau: {msg}")

    # 6️⃣ Gérer WifiAccess (session Internet)
    access = db.query(WifiAccess).filter(WifiAccess.user_id == user.id).first()

    if not access:
        access = WifiAccess(
            user_id=user.id,
            active=True,
            start_date=now,
            end_date=subscription.end_at,
            last_ip=ip,
            last_device_identifier=device_id,
            updated_at=now
        )
        db.add(access)
    else:
        access.active = True
        access.last_ip = ip
        access.last_device_identifier = device_id
        access.start_date = now
        access.end_date = subscription.end_at
        access.updated_at = now

    # 7️⃣ Historique
    history = log_connection_history(
        db=db,
        user_id=user.id,
        device_id=device.id,
        ip=ip,
        user_agent=ua,
        voucher_code=subscription.voucher_code,
        success=True,
        note="Activation WiFi"
    )

    db.commit()
    return {
        "message": "Internet activé",
        "expires": subscription.end_at,
        "history_id": history.id,
        "device_id": device.identifier
    }


# ============================================================
# 🛑 DÉSACTIVER INTERNET
# ============================================================
@router.post("/deactivate")
def deactivate_wifi(request: Request, db: Session = Depends(get_db), user=Depends(get_current_user)):
    now = datetime.utcnow()

    ok, msg = wifi_manager.deactivate_wifi(user.id)
    if not ok:
        access = db.query(WifiAccess).filter(WifiAccess.user_id == user.id).first()
        if access:
            access.active = False
            access.updated_at = now
            db.commit()
        raise HTTPException(500, f"Impossible de couper le réseau: {msg}")

    access = db.query(WifiAccess).filter(WifiAccess.user_id == user.id).first()
    if access:
        access.active = False
        access.updated_at = now
        db.commit()

    last_session = db.query(ConnectionHistory).filter(
        ConnectionHistory.user_id == user.id,
        ConnectionHistory.end_at == None
    ).order_by(ConnectionHistory.start_at.desc()).first()

    if last_session:
        close_connection_history(db, last_session.id, note="Déconnexion manuelle")

    return {"message": "Internet désactivé"}


# ============================================================
# 📡 STATUS
# ============================================================
@router.get("/status")
def wifi_status(db: Session = Depends(get_db), user=Depends(get_current_user)):
    access = db.query(WifiAccess).filter(WifiAccess.user_id == user.id).first()

    if not access:
        return {"active": False, "message": "Aucun accès WiFi enregistré."}

    now = datetime.utcnow()
    expired = now >= access.end_date

    ok, status_msg = wifi_manager.get_status(user.id)

    return {
        "active": access.active and not expired and ok,
        "expires": access.end_date,
        "expired": expired,
        "last_ip": access.last_ip,
        "device": access.last_device_identifier,
        "router_status": status_msg
    }
