# backend/src/services/voucher_service.py

import qrcode
import random
import string
from datetime import datetime, timedelta
from io import BytesIO
import base64

from sqlalchemy.orm import Session

from ..models import Voucher, Subscription


# ============================================================
# 🔤 GÉNÉRATION DE CODE (Pro)
# ============================================================
def generate_code() -> str:
    """Crée un code stylé : AB45-9DKQ-XX88"""
    def block():
        return ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
    return f"{block()}-{block()}-{block()}"


# ============================================================
# 🔳 QR CODE en Base64
# ============================================================
def generate_qr(data: str) -> str:
    """Génère un QR CODE en Base64 PNG."""
    qr = qrcode.make(data)
    buffer = BytesIO()
    qr.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode()


# ============================================================
# 🎟️ CRÉATION D’UN VOUCHER
# ============================================================
def create_voucher(db: Session, type: str, duration: int, max_devices: int = 1) -> Voucher:
    code = generate_code()
    qr = generate_qr(code)

    voucher = Voucher(
        code=code,
        qr_data=qr,
        type=type,
        duration_minutes=duration,
        max_devices=max_devices
    )

    db.add(voucher)
    db.commit()
    db.refresh(voucher)

    return voucher


# ============================================================
# 🧾 VALIDATION / UTILISATION D’UN VOUCHER
# ============================================================
def redeem_voucher(db: Session, voucher: Voucher, user_id: int) -> Subscription:
    """
    Active le voucher pour un utilisateur.

    - individual → 1 seule utilisation
    - business → multi-utilisateurs jusqu'à max_devices
    """

    # ------------------------------------------------------------
    # Individual : usage unique
    # ------------------------------------------------------------
    if voucher.type == "individual" and voucher.is_used:
        raise ValueError("Ce code est déjà utilisé.")

    # ------------------------------------------------------------
    # Business : plusieurs utilisateurs, mais limité
    # ------------------------------------------------------------
    if voucher.type == "business":
        count = db.query(Subscription).filter(
            Subscription.voucher_code == voucher.code,
            Subscription.is_active == True
        ).count()

        if count >= voucher.max_devices:
            raise ValueError("Limite d'utilisateurs atteinte pour ce code.")

    # ------------------------------------------------------------
    # Création de l’abonnement
    # ------------------------------------------------------------
    start = datetime.utcnow()
    end = start + timedelta(minutes=voucher.duration_minutes)

    sub = Subscription(
        user_id=user_id,
        plan_id=None,
        voucher_code=voucher.code,
        start_at=start,
        end_at=end,
        is_active=True,
        auto_renew=False
    )

    db.add(sub)

    # ------------------------------------------------------------
    # Marquer utilisé (INDIVIDUAL uniquement)
    # ------------------------------------------------------------
    if voucher.type == "individual":
        voucher.is_used = True
        voucher.used_by = user_id
        voucher.used_at = datetime.utcnow()

    db.commit()
    db.refresh(sub)

    return sub
