from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..db import get_db
from ..models import Payment, Plan
from ..security import get_current_user
import uuid, datetime, os, requests

router = APIRouter(prefix="/payments", tags=["Payments"])

@router.post("/create")
def create_payment(plan_id: int, method: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    plan = db.query(Plan).filter(Plan.id==plan_id).first()
    if not plan:
        raise HTTPException(404, "Plan not found")
    ref = str(uuid.uuid4())
    p = Payment(
        user_id=user.id,
        method=method,
        plan=plan.name,
        amount=plan.price,
        currency="GNF",
        status="pending",
        reference=ref,
        created_at=datetime.datetime.utcnow()
    )
    db.add(p)
    db.commit()
    db.refresh(p)

    # Exemple: si provider=mock, retourne checkout info
    if method == "mock":
        return {"checkout_id": ref, "payment_url": None, "reference": ref}

    # Ici implémente appel au provider (Orange/Mtn...). Retourne checkout info.
    return {"reference": ref}
