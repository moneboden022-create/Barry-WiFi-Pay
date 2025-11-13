
from fastapi import APIRouter, HTTPException
from sqlalchemy import select
from src.db import SessionLocal
from src.models import Payment, WifiAccess

router = APIRouter()

# ---------------------------------------------------------------
# Liste de tous les paiements
# ---------------------------------------------------------------
@router.get("/payments")
def list_payments():
    with SessionLocal() as db:
        rows = db.execute(select(Payment)).scalars().all()
        result = [
            {
                "id": p.id,
                "user_id": p.user_id,
                "method": p.method,
                "plan": p.plan,
                "amount": p.amount,
                "currency": p.currency,
                "status": p.status,
                "created_at": str(p.created_at),
            }
            for p in rows
        ]
        return {"count": len(result), "payments": result}


# ---------------------------------------------------------------
# Liste des accès Wi-Fi (actifs ou expirés)
# ---------------------------------------------------------------
@router.get("/wifi")
def list_wifi_access():
    with SessionLocal() as db:
        rows = db.execute(select(WifiAccess)).scalars().all()
        result = [
            {
                "id": w.id,
                "user_id": w.user_id,
                "active": w.active,
                "start_date": str(w.start_date),
                "end_date": str(w.end_date),
                "updated_at": str(w.updated_at),
            }
            for w in rows
        ]
        return {"count": len(result), "wifi_access": result}