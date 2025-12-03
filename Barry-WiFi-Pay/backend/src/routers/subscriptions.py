# backend/src/routers/subscriptions.py

from datetime import datetime, timedelta
from typing import List
from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Subscription, Plan, Voucher, WifiAccess
from ..security import get_current_user
from ..schemas import SubscriptionOut
from ..utils import (
    get_active_subscription,
    get_or_create_device,
    log_connection_history,
    cleanup_old_devices,
    count_user_devices,
)
from ..services.network.providers import WifiNetworkManager

# 🔁 Optional fallback: Starlink online check
try:
    from ..services.starlink import starlink_is_online
except:
    def starlink_is_online():
        return False    # fallback safe

router = APIRouter(prefix="/subscriptions", tags=["Subscriptions"])
wifi_manager = WifiNetworkManager()


# =====================================================================
# 📋 GET MY SUBSCRIPTIONS (Pour Flutter)
# =====================================================================
@router.get("/mine", response_model=List[SubscriptionOut])
def get_my_subscriptions(
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    """
    Récupère tous les abonnements de l'utilisateur connecté.
    Utilisé par Flutter pour afficher l'historique des abonnements.
    """
    subscriptions = db.query(Subscription).filter(
        Subscription.user_id == user.id
    ).order_by(Subscription.created_at.desc()).all()
    
    return subscriptions


# =====================================================================
# 📋 GET ACTIVE SUBSCRIPTION
# =====================================================================
@router.get("/active", response_model=SubscriptionOut)
def get_active_subscription_endpoint(
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    """
    Récupère l'abonnement actif de l'utilisateur.
    """
    subscription = get_active_subscription(db, user.id)
    if not subscription:
        raise HTTPException(404, "Aucun abonnement actif.")
    
    return subscription


# =====================================================================
# 🔥 BUY PLAN
# =====================================================================
@router.post("/buy")
def buy_subscription(
    request: Request,
    plan_id: int,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    plan = db.query(Plan).filter(Plan.id == plan_id).first()
    if not plan:
        raise HTTPException(404, "Forfait introuvable")

    # Vérifier forfait existant
    active = get_active_subscription(db, user.id)
    if active:
        raise HTTPException(403, "Vous avez déjà un forfait actif.")

    start_at = datetime.utcnow()
    end_at = start_at + timedelta(minutes=plan.duration_minutes)

    sub = Subscription(
        user_id=user.id,
        plan_id=plan.id,
        start_at=start_at,
        end_at=end_at,
        is_active=True,
        auto_renew=False
    )
    db.add(sub)

    # --------- Device obligatoire ----------
    device_identifier = request.headers.get("X-Device-ID")
    if not device_identifier:
        raise HTTPException(400, "X-Device-ID manquant")

    ua = request.headers.get("User-Agent", "")
    ip = request.client.host if request.client else None

    # Créer/update device
    device = get_or_create_device(db, user.id, device_identifier, ip, ua)

    # Nettoyage selon plan
    cleanup_old_devices(db, user.id, plan.max_devices)

    # --------- Activation réseau ----------
    ok, msg = wifi_manager.activate_wifi(user.id)
    if not ok:
        if not starlink_is_online():
            raise HTTPException(500, f"Routeur hors-ligne: {msg}")
        raise HTTPException(500, f"Activation failed: {msg}")

    # --------- WifiAccess ----------
    wifi = WifiAccess(
        user_id=user.id,
        active=True,
        start_date=start_at,
        end_date=end_at,
        last_ip=ip,
        last_device_identifier=device_identifier,
        updated_at=start_at
    )
    db.add(wifi)

    # Historique
    log_connection_history(
        db=db,
        user_id=user.id,
        device_id=device.id,
        ip=ip,
        user_agent=ua,
        voucher_code=None,
        success=True,
        note="Achat plan"
    )

    db.commit()
    return {"message": "Forfait activé", "expires": end_at}


# =====================================================================
# 🔥 USE VOUCHER
# =====================================================================
@router.post("/use-voucher")
def use_voucher(
    request: Request,
    code: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    voucher = db.query(Voucher).filter(Voucher.code == code).first()
    if not voucher:
        raise HTTPException(404, "Code invalide")

    # --------- Individual ---------
    if voucher.type == "individual" and voucher.is_used:
        raise HTTPException(403, "Ce voucher est déjà utilisé")

    # --------- Business multi-device ---------
    if voucher.type == "business":
        active_count = db.query(Subscription).filter(
            Subscription.voucher_code == voucher.code,
            Subscription.is_active == True
        ).count()
        if active_count >= voucher.max_devices:
            raise HTTPException(403, "Limite d'utilisation atteinte")

    start = datetime.utcnow()
    end = start + timedelta(minutes=voucher.duration_minutes)

    sub = Subscription(
        user_id=user.id,
        plan_id=None,
        voucher_code=voucher.code,
        start_at=start,
        end_at=end,
        is_active=True,
        auto_renew=False
    )
    db.add(sub)

    # Individual → marquer utilisé
    if voucher.type == "individual":
        voucher.is_used = True
        voucher.used_by = user.id
        voucher.used_at = datetime.utcnow()

    # --------- Device obligatoire ---------
    device_identifier = request.headers.get("X-Device-ID")
    if not device_identifier:
        raise HTTPException(400, "X-Device-ID manquant")

    ua = request.headers.get("User-Agent", "")
    ip = request.client.host if request.client else None

    device = get_or_create_device(db, user.id, device_identifier, ip, ua)
    cleanup_old_devices(db, user.id, voucher.max_devices)

    # --------- Activation réseau ---------
    ok, msg = wifi_manager.activate_wifi(user.id)
    if not ok:
        raise HTTPException(500, f"Activation failed: {msg}")

    wifi = WifiAccess(
        user_id=user.id,
        active=True,
        start_date=start,
        end_date=end,
        last_ip=ip,
        last_device_identifier=device_identifier,
        updated_at=start
    )
    db.add(wifi)

    log_connection_history(
        db=db,
        user_id=user.id,
        device_id=device.id,
        ip=ip,
        user_agent=ua,
        voucher_code=voucher.code,
        success=True,
        note="Activation via voucher"
    )

    db.commit()
    return {"message": "Internet activé via voucher", "expires": end}
