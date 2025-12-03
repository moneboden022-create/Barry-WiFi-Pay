from fastapi import APIRouter, Request, HTTPException, Depends
from sqlalchemy.orm import Session
from ..db import get_db
from ..models import Payment
import hmac, hashlib, os

router = APIRouter()

@router.post("/payments/webhook")
async def payment_webhook(request: Request, db: Session = Depends(get_db)):
    payload = await request.body()
    headers = request.headers

    # Vérifier signature (exemple HMAC-SHA256)
    secret = os.getenv("PAYMENT_WEBHOOK_SECRET", "change_me")
    signature = headers.get("X-Signature")
    if signature:
        mac = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
        if not hmac.compare_digest(mac, signature):
            raise HTTPException(status_code=401, detail="Invalid signature")

    data = await request.json()
    ref = data.get("reference")
    status = data.get("status")  # 'success' ou 'failed'

    payment = db.query(Payment).filter(Payment.reference==ref).first()
    if not payment:
        raise HTTPException(404, "Payment not found")

    if payment.status != "success":
        payment.status = status
        payment.provider_transaction_id = data.get("transaction_id")
        db.commit()

        if status == "success":
            # créer subscription / voucher flow comme dans /subscriptions/buy
            # ... (logique identique) ...
            pass

    return {"ok": True}
