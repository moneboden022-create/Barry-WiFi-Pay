# backend/src/routers/admin.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime
from typing import Optional
import uuid

from ..db import get_db
from ..security import get_current_user
from ..models import (
    User,
    Payment,
    Subscription,
    WifiAccess,
    ConnectionHistory,
    Device,
    Voucher,
)
from ..services.network.providers import WifiNetworkManager

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])

# Network Manager
_network = WifiNetworkManager()


# --------------------------------------------------------
# Helpers
# --------------------------------------------------------
def admin_required(user: User):
    if not getattr(user, "is_admin", False):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN,
                            detail="Accès réservé aux administrateurs")
    return True


def serialize_user(u: User):
    return {
        "id": u.id,
        "first_name": u.first_name,
        "last_name": u.last_name,
        "phone_number": u.phone_number,
        "country": u.country,
        "isBusiness": u.isBusiness,
        "company_name": u.company_name,
        "max_devices_allowed": u.max_devices_allowed,
        "is_active": u.is_active,
        "is_admin": getattr(u, "is_admin", False),
        "created_at": str(u.created_at),
    }


def serialize_payment(p: Payment):
    return {
        "id": p.id,
        "user_id": p.user_id,
        "method": p.method,
        "plan": p.plan,
        "amount": p.amount,
        "currency": p.currency,
        "status": p.status,
        "reference": p.reference,
        "provider_transaction_id": p.provider_transaction_id,
        "created_at": str(p.created_at),
    }


# --------------------------------------------------------
# STATS
# --------------------------------------------------------
@router.get("/stats")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    now = datetime.utcnow()
    today_start = datetime(now.year, now.month, now.day)

    return {
        "users": db.query(func.count(User.id)).scalar() or 0,
        "subscriptions": {
            "active": db.query(func.count(Subscription.id))
                .filter(Subscription.is_active == True, Subscription.end_at > now)
                .scalar() or 0,
            "expired": db.query(func.count(Subscription.id))
                .filter(Subscription.end_at <= now)
                .scalar() or 0
        },
        "devices": db.query(func.count(Device.id)).scalar() or 0,
        "connections": {
            "today": db.query(func.count(ConnectionHistory.id))
                .filter(ConnectionHistory.start_at >= today_start)
                .scalar() or 0
        },
        "wifi": {
            "active": db.query(func.count(WifiAccess.id))
                .filter(WifiAccess.active == True)
                .scalar() or 0,
            "inactive": db.query(func.count(WifiAccess.id))
                .filter(WifiAccess.active == False)
                .scalar() or 0
        },
        "vouchers": {
            "created": db.query(func.count(Voucher.id)).scalar() or 0,
            "used": db.query(func.count(Voucher.id))
                .filter(Voucher.is_used == True)
                .scalar() or 0
        },
        "revenue": {
            "total": db.query(func.coalesce(func.sum(Payment.amount), 0)).scalar(),
            "today": db.query(func.coalesce(func.sum(Payment.amount), 0))
                .filter(Payment.created_at >= today_start)
                .scalar()
        }
    }


# --------------------------------------------------------
# USERS
# --------------------------------------------------------
@router.get("/users")
def list_users(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    q: Optional[str] = None,
    limit: int = 100,
    offset: int = 0
):
    admin_required(user)

    query = db.query(User)
    if q:
        like = f"%{q}%"
        query = query.filter(
            (User.first_name.ilike(like)) |
            (User.last_name.ilike(like)) |
            (User.phone_number.ilike(like))
        )

    rows = query.order_by(User.id.desc()).limit(limit).offset(offset).all()
    return {"count": len(rows), "users": [serialize_user(u) for u in rows]}


@router.get("/users/{user_id}")
def get_user_detail(
    user_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)
    u = db.query(User).filter(User.id == user_id).first()

    if not u:
        raise HTTPException(404, "Utilisateur non trouvé")

    return serialize_user(u)


@router.post("/users/set-admin/{user_id}")
def set_admin_role(
    user_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)
    u = db.query(User).filter(User.id == user_id).first()

    if not u:
        raise HTTPException(404, "Utilisateur non trouvé")

    u.is_admin = True
    db.commit()
    return {"ok": True, "user": serialize_user(u)}


@router.post("/users/remove-admin/{user_id}")
def remove_admin_role(
    user_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)
    u = db.query(User).filter(User.id == user_id).first()

    if not u:
        raise HTTPException(404, "Utilisateur non trouvé")

    u.is_admin = False
    db.commit()
    return {"ok": True, "user": serialize_user(u)}


@router.delete("/users/{user_id}")
def delete_user_account(
    user_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)
    u = db.query(User).filter(User.id == user_id).first()

    if not u:
        raise HTTPException(404, "Utilisateur non trouvé")

    db.delete(u)
    db.commit()
    return {"ok": True}


# --------------------------------------------------------
# DEVICES
# --------------------------------------------------------
@router.get("/devices")
def list_devices(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    limit: int = 200,
    offset: int = 0
):
    admin_required(user)

    rows = db.query(Device).order_by(Device.last_seen.desc()).limit(limit).offset(offset).all()

    return {"count": len(rows), "devices": [
        {
            "id": d.id,
            "user_id": d.user_id,
            "identifier": d.identifier,
            "user_agent": d.user_agent,
            "ip": d.ip,
            "is_blocked": d.is_blocked,
            "last_seen": str(d.last_seen)
        } for d in rows
    ]}


@router.post("/devices/block/{device_id}")
def block_device(
    device_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)
    d = db.query(Device).filter(Device.id == device_id).first()

    if not d:
        raise HTTPException(404, "Device non trouvé")

    d.is_blocked = True
    db.commit()
    return {"ok": True}


@router.post("/devices/unblock/{device_id}")
def unblock_device(
    device_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)
    d = db.query(Device).filter(Device.id == device_id).first()

    if not d:
        raise HTTPException(404, "Device non trouvé")

    d.is_blocked = False
    db.commit()
    return {"ok": True}


# --------------------------------------------------------
# WIFI ACCESS
# --------------------------------------------------------
@router.get("/wifi")
def list_wifi_access(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    limit: int = 200,
    offset: int = 0
):
    admin_required(user)

    rows = db.query(WifiAccess).order_by(WifiAccess.id.desc()).limit(limit).offset(offset).all()

    return {"count": len(rows), "wifi_access": [
        {
            "id": w.id,
            "user_id": w.user_id,
            "active": w.active,
            "start_date": str(w.start_date),
            "end_date": str(w.end_date),
            "updated_at": str(w.updated_at),
            "last_ip": w.last_ip,
            "device": w.last_device_identifier
        } for w in rows
    ]}


@router.post("/wifi/disable/{user_id}")
def disable_wifi_admin(
    user_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    w = db.query(WifiAccess).filter(WifiAccess.user_id == user_id).first()

    if not w:
        raise HTTPException(404, "Wifi access non trouvé")

    w.active = False
    w.updated_at = datetime.utcnow()
    db.commit()

    return {"ok": True}


# --------------------------------------------------------
# SUBSCRIPTIONS
# --------------------------------------------------------
@router.get("/subscriptions")
def list_subscriptions(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    limit: int = 200,
    offset: int = 0
):
    admin_required(user)

    rows = db.query(Subscription).order_by(Subscription.id.desc()).limit(limit).offset(offset).all()

    return {"count": len(rows), "subscriptions": [
        {
            "id": s.id,
            "user_id": s.user_id,
            "plan_id": s.plan_id,
            "voucher_code": s.voucher_code,
            "start_at": str(s.start_at),
            "end_at": str(s.end_at),
            "is_active": s.is_active,
            "auto_renew": s.auto_renew
        } for s in rows
    ]}


@router.get("/subscriptions/active")
def list_active_subs(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    now = datetime.utcnow()
    rows = db.query(Subscription).filter(
        Subscription.is_active == True,
        Subscription.end_at > now
    ).all()

    return {"count": len(rows), "subscriptions": [
        {"id": s.id, "user_id": s.user_id, "end_at": str(s.end_at)}
        for s in rows
    ]}


@router.get("/subscriptions/expired")
def list_expired_subs(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    now = datetime.utcnow()
    rows = db.query(Subscription).filter(Subscription.end_at <= now).all()

    return {"count": len(rows), "subscriptions": [
        {"id": s.id, "user_id": s.user_id, "end_at": str(s.end_at)}
        for s in rows
    ]}


# --------------------------------------------------------
# VOUCHERS
# --------------------------------------------------------
@router.get("/vouchers")
def list_vouchers(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    limit: int = 200,
    offset: int = 0
):
    admin_required(user)

    rows = db.query(Voucher).order_by(Voucher.id.desc()).limit(limit).offset(offset).all()

    return {"count": len(rows), "vouchers": [
        {
            "id": v.id,
            "code": v.code,
            "type": v.type,
            "duration_minutes": v.duration_minutes,
            "max_devices": v.max_devices,
            "is_used": v.is_used,
            "used_by": v.used_by,
            "created_at": str(v.created_at),
            "used_at": str(v.used_at) if v.used_at else None
        } for v in rows
    ]}


@router.get("/vouchers/used")
def list_used_vouchers(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    rows = db.query(Voucher).filter(Voucher.is_used == True).all()

    return {"count": len(rows), "vouchers": [
        {
            "id": v.id,
            "code": v.code,
            "used_by": v.used_by,
            "used_at": str(v.used_at)
        } for v in rows
    ]}


# -----------------------------
# ADMIN: Create Voucher
# -----------------------------
@router.post("/vouchers/create")
def admin_create_voucher(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    # Générer un code propre
    code = str(uuid.uuid4())[:8].upper()

    voucher = Voucher(
        code=code,
        type="admin",
        duration_minutes=60,
        max_devices=1,
        created_at=datetime.utcnow()
    )

    db.add(voucher)
    db.commit()
    db.refresh(voucher)

    return {"voucher": code}


# --------------------------------------------------------
# PAYMENTS
# --------------------------------------------------------
@router.get("/payments/all")
def list_payments(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    rows = db.query(Payment).order_by(Payment.id.desc()).all()

    return {"count": len(rows), "payments": [serialize_payment(p) for p in rows]}


# --------------------------------------------------------
# CONNECTION HISTORY
# --------------------------------------------------------
@router.get("/connections")
def list_connections(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    limit: int = 500,
    offset: int = 0
):
    admin_required(user)

    rows = db.query(ConnectionHistory).order_by(ConnectionHistory.id.desc()).limit(limit).offset(offset).all()

    return {"count": len(rows), "connections": [
        {
            "id": h.id,
            "user_id": h.user_id,
            "device_id": h.device_id,
            "ip": h.ip,
            "voucher_code": h.voucher_code,
            "user_agent": h.user_agent,
            "start_at": str(h.start_at),
            "end_at": str(h.end_at),
            "success": h.success,
            "note": h.note
        } for h in rows
    ]}


# --------------------------------------------------------
# SYSTEM
# --------------------------------------------------------
@router.get("/system/router-status")
def router_status(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    admin_required(user)

    ok, msg = _network.get_status(user_id=0)
    return {"ok": ok, "message": msg}
