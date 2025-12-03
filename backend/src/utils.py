# backend/src/utils.py

import random
import string
from datetime import datetime
from sqlalchemy.orm import Session

from . import models


# ============================================================
# 1️⃣ GENERATION DE CODES (voucher / activation / OTP)
# ============================================================

def generate_code(length: int = 10) -> str:
    """Génère un code simple (voucher standard)."""
    chars = string.ascii_uppercase + string.digits
    return ''.join(random.choice(chars) for _ in range(length))


def generate_secure_code(length: int = 16) -> str:
    """Génère un code plus sécurisé (QR Business / VIP)."""
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))


def generate_otp(length: int = 6) -> str:
    """Génère un OTP numérique pour SMS."""
    return ''.join(random.choice(string.digits) for _ in range(length))


# ============================================================
# 2️⃣ USERS (lookup)
# ============================================================

def get_user_by_phone(db: Session, phone: str):
    return db.query(models.User).filter(models.User.phone_number == phone).first()


def get_user_by_email(db: Session, email: str):
    """Recherche un utilisateur par email."""
    return db.query(models.User).filter(models.User.email == email).first()


def get_user_by_identifier(db: Session, identifier: str):
    """
    🔥 Recherche un utilisateur par identifier (email OU téléphone).
    - Si contient '@' → recherche par email
    - Sinon → recherche par phone_number
    """
    if not identifier:
        return None
    
    # Nettoyer l'identifiant
    identifier = identifier.strip()
    
    # Si c'est un email (contient @)
    if '@' in identifier:
        return get_user_by_email(db, identifier)
    
    # Sinon, c'est un numéro de téléphone
    return get_user_by_phone(db, identifier)


def get_user_by_id(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()


# ============================================================
# 3️⃣ DEVICES (gestion multi-appareils propre)
# ============================================================

def get_or_create_device(
    db: Session,
    user_id: int,
    identifier: str,
    ip: str,
    user_agent: str
):
    """
    Récupère ou crée un device.
    """
    now = datetime.utcnow()

    device = db.query(models.Device).filter(
        models.Device.user_id == user_id,
        models.Device.identifier == identifier
    ).first()

    if device:
        # Mise à jour
        device.last_seen = now
        device.ip = ip
        device.user_agent = user_agent
        db.commit()
        return device

    # Nouveau device
    new_device = models.Device(
        user_id=user_id,
        identifier=identifier,
        ip=ip,
        user_agent=user_agent,
        last_seen=now
    )
    db.add(new_device)
    db.commit()
    db.refresh(new_device)
    return new_device


def count_user_devices(db: Session, user_id: int) -> int:
    return db.query(models.Device).filter(models.Device.user_id == user_id).count()


def cleanup_old_devices(db: Session, user_id: int, max_devices: int):
    """
    Supprime les appareils les plus anciens si l'utilisateur dépasse la limite.
    """
    devices = (
        db.query(models.Device)
        .filter(models.Device.user_id == user_id)
        .order_by(models.Device.last_seen.asc())
        .all()
    )

    if len(devices) > max_devices:
        to_delete = len(devices) - max_devices
        for d in devices[:to_delete]:
            db.delete(d)
        db.commit()


# ============================================================
# 4️⃣ SUBSCRIPTION (forfait actif)
# ============================================================

def get_active_subscription(db: Session, user_id: int):
    now = datetime.utcnow()
    sub = db.query(models.Subscription).filter(
        models.Subscription.user_id == user_id,
        models.Subscription.is_active == True,
        models.Subscription.end_at > now
    ).first()
    return sub


# ============================================================
# 5️⃣ HISTORIQUE DES CONNEXIONS
# ============================================================

def log_connection_history(
    db: Session,
    user_id: int,
    device_id: int,
    ip: str,
    user_agent: str,
    voucher_code: str = None,
    success: bool = True,
    note: str = None
):
    entry = models.ConnectionHistory(
        user_id=user_id,
        device_id=device_id,
        ip=ip,
        user_agent=user_agent,
        voucher_code=voucher_code,
        start_at=datetime.utcnow(),
        success=success,
        note=note
    )

    db.add(entry)
    db.commit()
    db.refresh(entry)
    return entry


def close_connection_history(db: Session, history_id: int, note: str = None):
    history = db.query(models.ConnectionHistory).filter(
        models.ConnectionHistory.id == history_id
    ).first()

    if history:
        history.end_at = datetime.utcnow()
        if note:
            history.note = note
        db.commit()

    return history


# =========================================================
