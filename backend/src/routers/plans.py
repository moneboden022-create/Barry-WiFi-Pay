# backend/src/routers/plans.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional

from ..db import get_db
from .. import models, schemas
from ..security import get_current_user
from ..deps import admin_required

router = APIRouter(prefix="/plans", tags=["Plans"])


# ------------------------------------------------------------
# 🔒 Helper : Vérification rôle administrateur
# ------------------------------------------------------------
# Note: admin_required est maintenant importé depuis deps.py


# ============================================================
# ➕ CREATE PLAN (ADMIN)
# ============================================================
@router.post("/", response_model=schemas.PlanOut)
def create_plan(
    plan: schemas.PlanCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):

    new_plan = models.Plan(
        name=plan.name,
        price=plan.price,
        duration_minutes=plan.duration_minutes,
        isBusiness=plan.isBusiness,
        max_devices=plan.max_devices if plan.isBusiness else 1,
    )

    db.add(new_plan)
    db.commit()
    db.refresh(new_plan)
    return new_plan


# ============================================================
# 📋 LIST ALL PLANS (PUBLIC)
# ============================================================
@router.get("/", response_model=list[schemas.PlanOut])
def list_plans(
    db: Session = Depends(get_db),
    q: Optional[str] = None,
    order: str = "asc"
):
    query = db.query(models.Plan)

    if q:
        query = query.filter(models.Plan.name.ilike(f"%{q}%"))

    query = query.order_by(
        models.Plan.price.desc() if order == "desc" else models.Plan.price.asc()
    )

    return query.all()


# ============================================================
# 🏢 LIST BUSINESS PLANS
# ============================================================
@router.get("/business", response_model=list[schemas.PlanOut])
def list_business_plans(db: Session = Depends(get_db)):
    return (
        db.query(models.Plan)
        .filter(models.Plan.isBusiness == True)
        .order_by(models.Plan.price.asc())
        .all()
    )


# ============================================================
# 👤 LIST INDIVIDUAL PLANS
# ============================================================
@router.get("/individual", response_model=list[schemas.PlanOut])
def list_individual_plans(db: Session = Depends(get_db)):
    return (
        db.query(models.Plan)
        .filter(models.Plan.isBusiness == False)
        .order_by(models.Plan.price.asc())
        .all()
    )


# ============================================================
# 🔎 GET PLAN BY ID
# ============================================================
@router.get("/{plan_id}", response_model=schemas.PlanOut)
def get_plan(plan_id: int, db: Session = Depends(get_db)):
    plan = db.query(models.Plan).filter(models.Plan.id == plan_id).first()
    if not plan:
        raise HTTPException(404, "Plan introuvable.")
    return plan


# ============================================================
# ✏️ UPDATE PLAN (ADMIN)
# ============================================================
@router.put("/{plan_id}", response_model=schemas.PlanOut)
def update_plan(
    plan_id: int,
    plan: schemas.PlanCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):

    existing = db.query(models.Plan).filter(models.Plan.id == plan_id).first()
    if not existing:
        raise HTTPException(404, "Plan introuvable.")

    existing.name = plan.name
    existing.price = plan.price
    existing.duration_minutes = plan.duration_minutes
    existing.isBusiness = plan.isBusiness
    existing.max_devices = plan.max_devices if plan.isBusiness else 1

    db.commit()
    db.refresh(existing)
    return existing


# ============================================================
# 🗑️ DELETE PLAN (ADMIN)
# ============================================================
@router.delete("/{plan_id}")
def delete_plan(
    plan_id: int,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):

    plan = db.query(models.Plan).filter(models.Plan.id == plan_id).first()
    if not plan:
        raise HTTPException(404, "Plan introuvable.")

    db.delete(plan)
    db.commit()

    return {"message": "Plan supprimé avec succès."}
