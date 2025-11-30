# backend/src/routers/voucher.py

from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import qrcode
import base64
from io import BytesIO

from ..db import get_db
from ..models import Voucher, Subscription, WifiAccess
from ..security import get_current_user
from ..utils import (
    generate_code,
    get_or_create_device,
    cleanup_old_devices,
    log_connection_history,
    get_active_subscription,
)
from ..schemas import (
    VoucherCreate,
    VoucherOut,
    VoucherUseResponse,
    VoucherUseRequest,
)
from ..services.network.providers import WifiNetworkManager

router = APIRouter(prefix="/voucher", tags=["Vouchers"])
wifi_manager = WifiNetworkManager()


# ============================================================
# GENERATE VOUCHER (ADMIN)
# ============================================================
@router.post("/generate", response_model=VoucherOut)
def generate_voucher(
    data: VoucherCreate,
    db: Session = Depends(get_db),
):
    """
    Génère un voucher + QR code en Base64.
    """
    code = generate_code()

    # QR Code
    qr = qrcode.make(code)
    buffer = BytesIO()
    qr.save(buffer, format="PNG")
    qr_b64 = base64.b64encode(buffer.getvalue()).decode()

    voucher = Voucher(
        code=code,
        type=data.type,
        duration_minutes=data.duration_minutes,
        max_devices=data.max_devices if data.type == "business" else 1,
        qr_data=qr_b64,
        created_at=datetime.utcnow(),
    )

    db.add(voucher)
    db.commit()
    db.refresh(voucher)

    return voucher


# ============================================================
# USE VOUCHER
# ============================================================
@router.post("/use", response_model=VoucherUseResponse)
def use_voucher(
    request: Request,
    data: VoucherUseRequest,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    """
    Active internet via voucher.
    Gestion :
    - individual → 1 seule utilisation
    - business → multi-appareils (max_devices)
    """
    voucher = db.query(Voucher).filter(Voucher.code == data.code).first()
    if not voucher:
        raise HTTPException(404, "Code invalide")

    # Vérifier si l'utilisateur a déjà un forfait actif
    active = get_active_subscription(db, user.id)
    if active:
        raise HTTPException(403, "Vous avez déjà un forfait actif")

    # Vérifier l'identifiant appareil
    device_identifier = request.headers.get("X-Device-ID")
    if not device_identifier:
        raise HTTPException(400, "X-Device-ID manquant")

    ua = request.headers.get("User-Agent", "")
    ip = request.client.host if request.client else None

    # Individual : usage unique
    if voucher.type == "individual":
        if voucher.is_used:
            raise HTTPException(400, "Ce voucher a déjà été utilisé.")

    # Business : multi-appareils
    if voucher.type == "business":
        active_count = (
            db.query(Subscription)
            .filter(
                Subscription.voucher_code == voucher.code,
                Subscription.is_active == True,
            )
            .count()
        )
        if active_count >= voucher.max_devices:
            raise HTTPException(403, "Limite d'appareils atteinte.")

    # Enregistrer l'appareil
    device = get_or_create_device(db, user.id, device_identifier, ip, ua)

    # Nettoyage des anciens appareils
    cleanup_old_devices(db, user.id, voucher.max_devices)

    # Activer abonnement
    start_at = datetime.utcnow()
    end_at = start_at + timedelta(minutes=voucher.duration_minutes)

    subscription = Subscription(
        user_id=user.id,
        plan_id=None,
        voucher_code=voucher.code,
        start_at=start_at,
        end_at=end_at,
        is_active=True,
        auto_renew=False,
    )
    db.add(subscription)

    # Marquer voucher comme utilisé
    if voucher.type == "individual":
        voucher.is_used = True
        voucher.used_by = user.id
        voucher.used_at = datetime.utcnow()

    # Activer Wi-Fi
    ok, msg = wifi_manager.activate_wifi(user.id)
    if not ok:
        raise HTTPException(500, f"Activation échouée : {msg}")

    # Enregistrer accès Wi-Fi
    wifi = WifiAccess(
        user_id=user.id,
        active=True,
        start_date=start_at,
        end_date=end_at,
        last_ip=ip,
        last_device_identifier=device_identifier,
        updated_at=start_at,
    )
    db.add(wifi)

    # Historique connexion
    log_connection_history(
        db=db,
        user_id=user.id,
        device_id=device.id,
        ip=ip,
        user_agent=ua,
        voucher_code=voucher.code,
        success=True,
        note="Activation via voucher",
    )

    db.commit()

    return VoucherUseResponse(
        success=True,
        expires=end_at,
    )
