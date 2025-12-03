# backend/src/routers/history.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import ConnectionHistory, User
from ..security import get_current_user

router = APIRouter(prefix="/history", tags=["History"])


# -------------------------------------------------------------
# 🔥 1. HISTORIQUE DE L’UTILISATEUR CONNECTÉ
# -------------------------------------------------------------
@router.get("/me")
def user_history(db: Session = Depends(get_db), user=Depends(get_current_user)):
    rows = (
        db.query(ConnectionHistory)
        .filter(ConnectionHistory.user_id == user.id)
        .order_by(ConnectionHistory.start_at.desc())
        .all()
    )

    return [
        {
            "id": h.id,
            "user_id": h.user_id,
            "device_id": h.device_id,
            "ip": h.ip,
            "user_agent": h.user_agent,
            "voucher_code": h.voucher_code,
            "start_at": str(h.start_at),
            "end_at": str(h.end_at) if h.end_at else None,
            "success": h.success,
            "note": h.note,
        }
        for h in rows
    ]


# -------------------------------------------------------------
# 🔥 2. HISTORIQUE GLOBAL (ADMIN SEULEMENT)
# -------------------------------------------------------------
@router.get("/all")
def all_history(db: Session = Depends(get_db), user=Depends(get_current_user)):

    # Vérifier rôle admin
    if not getattr(user, "is_admin", False):
        raise HTTPException(403, "Accès réservé aux administrateurs.")

    rows = (
        db.query(ConnectionHistory)
        .order_by(ConnectionHistory.start_at.desc())
        .all()
    )

    return [
        {
            "id": h.id,
            "user_id": h.user_id,
            "device_id": h.device_id,
            "ip": h.ip,
            "user_agent": h.user_agent,
            "voucher_code": h.voucher_code,
            "start_at": str(h.start_at),
            "end_at": str(h.end_at) if h.end_at else None,
            "success": h.success,
            "note": h.note,
        }
        for h in rows
    ]
