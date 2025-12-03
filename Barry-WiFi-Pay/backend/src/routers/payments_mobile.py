# backend/src/routers/payments_mobile.py
"""
💳 Système de Paiement Mobile Money - BARRY WiFi
Préparation pour intégration Orange Money & MTN Money

TODO: Payment integration - À implémenter
- Orange Money API (Guinée)
- MTN Mobile Money API
- Callback webhooks
- Validation des paiements
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from ..db import get_db
from ..security import get_current_user
from ..models import User, Payment

router = APIRouter(prefix="/payments", tags=["Payments (Coming Soon)"])


# ============================================================
# SCHEMAS (Préparation)
# ============================================================
class PaymentInitRequest(BaseModel):
    """Demande d'initialisation de paiement"""
    amount: int
    currency: str = "GNF"
    method: str  # orange_money, mtn_money
    phone_number: str
    plan_id: Optional[int] = None
    voucher_type: Optional[str] = None


class PaymentStatusResponse(BaseModel):
    """Réponse de statut de paiement"""
    payment_id: int
    status: str  # pending, processing, completed, failed
    amount: int
    currency: str
    method: str
    reference: str
    created_at: str


# ============================================================
# 💳 INITIER UN PAIEMENT
# ============================================================
@router.post("/initiate")
async def initiate_payment(
    data: PaymentInitRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """
    TODO: Payment integration
    
    Initialise un paiement mobile money.
    Cette route sera connectée aux APIs Orange Money et MTN Money.
    """
    
    # Validation du montant minimum
    if data.amount < 500:
        raise HTTPException(400, "Montant minimum: 500 GNF")
    
    # Validation de la méthode de paiement
    valid_methods = ["orange_money", "mtn_money"]
    if data.method not in valid_methods:
        raise HTTPException(400, f"Méthode invalide. Choix: {valid_methods}")
    
    # TODO: Appeler l'API du fournisseur de paiement
    # - Orange Money: https://developer.orange.com/apis/
    # - MTN Money: https://momodeveloper.mtn.com/
    
    # Créer l'enregistrement de paiement (en attente)
    payment = Payment(
        user_id=user.id,
        method=data.method,
        amount=data.amount,
        currency=data.currency,
        status="pending",  # TODO: Changer après intégration API
        reference=f"BWIFI-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{user.id}",
        plan=f"voucher_{data.voucher_type}" if data.voucher_type else f"plan_{data.plan_id}",
        created_at=datetime.utcnow()
    )
    
    db.add(payment)
    db.commit()
    db.refresh(payment)
    
    # TODO: Retourner l'URL de paiement ou le code USSD
    return {
        "ok": True,
        "payment_id": payment.id,
        "reference": payment.reference,
        "status": "pending",
        "message": "💳 Paiement mobile money bientôt disponible!",
        "instructions": {
            "orange_money": "Composez *144# et suivez les instructions",
            "mtn_money": "Composez *170# et suivez les instructions"
        },
        # TODO: Ajouter ces champs après intégration
        # "payment_url": "https://...",
        # "ussd_code": "*144*...",
        # "qr_code": "base64..."
    }


# ============================================================
# 📋 STATUT D'UN PAIEMENT
# ============================================================
@router.get("/status/{payment_id}")
async def get_payment_status(
    payment_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Vérifie le statut d'un paiement"""
    
    payment = db.query(Payment).filter(
        Payment.id == payment_id,
        Payment.user_id == user.id
    ).first()
    
    if not payment:
        raise HTTPException(404, "Paiement non trouvé")
    
    # TODO: Vérifier le statut auprès du fournisseur
    
    return PaymentStatusResponse(
        payment_id=payment.id,
        status=payment.status,
        amount=payment.amount,
        currency=payment.currency,
        method=payment.method,
        reference=payment.reference,
        created_at=str(payment.created_at)
    )


# ============================================================
# 📜 HISTORIQUE DES PAIEMENTS
# ============================================================
@router.get("/history")
async def get_payment_history(
    limit: int = 50,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Liste l'historique des paiements de l'utilisateur"""
    
    payments = db.query(Payment).filter(
        Payment.user_id == user.id
    ).order_by(Payment.created_at.desc()).limit(limit).all()
    
    return {
        "count": len(payments),
        "payments": [
            {
                "id": p.id,
                "amount": p.amount,
                "currency": p.currency,
                "method": p.method,
                "status": p.status,
                "reference": p.reference,
                "plan": p.plan,
                "created_at": str(p.created_at)
            }
            for p in payments
        ]
    }


# ============================================================
# 🔔 WEBHOOK CALLBACK (Pour les fournisseurs)
# ============================================================
@router.post("/webhook/{provider}")
async def payment_webhook(
    provider: str,
    db: Session = Depends(get_db)
):
    """
    TODO: Payment integration
    
    Webhook pour recevoir les notifications de paiement.
    Appelé automatiquement par Orange Money / MTN Money après paiement.
    """
    
    valid_providers = ["orange_money", "mtn_money"]
    if provider not in valid_providers:
        raise HTTPException(400, "Fournisseur invalide")
    
    # TODO: Valider la signature du webhook
    # TODO: Extraire les données de paiement
    # TODO: Mettre à jour le statut du paiement
    # TODO: Activer le voucher/plan si paiement réussi
    
    return {
        "received": True,
        "message": "Webhook reçu - TODO: Implémenter le traitement"
    }


# ============================================================
# 💰 TARIFS DISPONIBLES
# ============================================================
@router.get("/pricing")
async def get_pricing():
    """Retourne les tarifs disponibles pour achat"""
    
    return {
        "currency": "GNF",
        "plans": [
            {
                "id": 1,
                "name": "1 Heure",
                "duration_minutes": 60,
                "price": 500,
                "devices": 1
            },
            {
                "id": 2,
                "name": "3 Heures",
                "duration_minutes": 180,
                "price": 1000,
                "devices": 1
            },
            {
                "id": 3,
                "name": "Journée",
                "duration_minutes": 1440,
                "price": 2500,
                "devices": 1
            },
            {
                "id": 4,
                "name": "Semaine",
                "duration_minutes": 10080,
                "price": 10000,
                "devices": 1
            },
            {
                "id": 5,
                "name": "Business (3 appareils)",
                "duration_minutes": 1440,
                "price": 5000,
                "devices": 3
            },
            {
                "id": 6,
                "name": "Enterprise (10 appareils)",
                "duration_minutes": 1440,
                "price": 15000,
                "devices": 10
            }
        ],
        "payment_methods": [
            {
                "id": "orange_money",
                "name": "Orange Money",
                "icon": "🟠",
                "available": False,  # TODO: Changer à True après intégration
                "ussd": "*144#"
            },
            {
                "id": "mtn_money",
                "name": "MTN Mobile Money",
                "icon": "🟡",
                "available": False,  # TODO: Changer à True après intégration
                "ussd": "*170#"
            }
        ],
        "notice": "💳 Paiement mobile money bientôt disponible!"
    }

