# backend/src/routers/user.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime

from ..db import get_db
from ..models import User, Subscription, WifiAccess, Voucher
from ..security import get_current_user

router = APIRouter(prefix="/user", tags=["User"])

# ===================================================================
# 🔥 1. PROFIL UTILISATEUR
# ===================================================================
@router.get("/profile")
def get_profile(user: User = Depends(get_current_user)):
    return {
        "id": user.id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "phone_number": user.phone_number,
        "country": user.country,
        "isBusiness": user.isBusiness,
        "max_devices_allowed": user.max_devices_allowed,
        "is_active": user.is_active,
        "created_at": str(user.created_at)
    }

# ===================================================================
# 🔥 2. STATUT + TEMPS RESTANT + EXPIRATION (Flutter Timer)
# ===================================================================
@router.get("/status")
def user_status(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):

    now = datetime.utcnow()

    # -----------------------------
    # Vérifier abonnement actif
    # -----------------------------
    sub = (
        db.query(Subscription)
        .filter(
            Subscription.user_id == user.id,
            Subscription.is_active == True,
            Subscription.end_at > now
        )
        .order_by(Subscription.end_at.desc())
        .first()
    )

    # AUCUN ABONNEMENT ACTIF
    if not sub:
        return {
            "has_active": False,
            "remaining_minutes": 0,
            "expires_at": None,
            "active_type": None,
            "voucher_code": None,
            "voucher_type": None,
            "wifi_active": False,
        }

    # -----------------------------
    # Calcul minutes restantes
    # -----------------------------
    remaining_seconds = (sub.end_at - now).total_seconds()
    remaining_minutes = max(0, int(remaining_seconds // 60))

    # -----------------------------
    # Vérifier type : plan / voucher
    # -----------------------------
    voucher_code = sub.voucher_code
    voucher_type = None

    if voucher_code:
        v = db.query(Voucher).filter(Voucher.code == voucher_code).first()
        if v:
            voucher_type = v.type

    # -----------------------------
    # Vérifier WiFi actif
    # -----------------------------
    wifi = (
        db.query(WifiAccess)
        .filter(
            WifiAccess.user_id == user.id,
            WifiAccess.active == True,
            WifiAccess.end_date > now
        )
        .first()
    )

    # -----------------------------
    # RÉPONSE COMPLÈTE POUR FLUTTER
    # -----------------------------
    return {
        "has_active": True,
        "active_type": "voucher" if voucher_code else "plan",
        "voucher_code": voucher_code,
        "voucher_type": voucher_type,

        "remaining_minutes": remaining_minutes,
        "expires_at": str(sub.end_at),
        "start_at": str(sub.start_at),

        "wifi_active": True if wifi else False
    }
