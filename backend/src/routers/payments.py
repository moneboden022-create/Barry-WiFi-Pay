from fastapi import APIRouter
from pydantic import BaseModel
import os
from src.services.payments import PaymentsService

router = APIRouter()
svc = PaymentsService()

class CreatePaymentRequest(BaseModel):
    amount: float
    currency: str = "GNF"
    plan_id: str
    method: str  # "orange" | "mtn" | "paypal" | "visa" | "mock"

@router.post("/create")
def create_payment(payload: CreatePaymentRequest):
    res = svc.create_payment(
        amount=payload.amount,
        currency=payload.currency,
        plan_id=payload.plan_id,
        method=payload.method,
    )
    return res

class ConfirmPaymentRequest(BaseModel):
    payment_id: str

@router.post("/confirm")
def confirm_payment(payload: ConfirmPaymentRequest):
    res = svc.confirm_payment(payload.payment_id)
    return res
