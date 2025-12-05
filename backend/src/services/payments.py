import os
import uuid
from datetime import datetime
from sqlalchemy.orm import Session

from src.db import SessionLocal
from src.models import Payment, Plan
from src.services.payments.adapters import (
    MockAdapter, OrangeAdapter, MTNAdapter, PayPalAdapter, VisaAdapter
)


class PaymentsService:

    def __init__(self):
        # Mode mock pour les tests (par défaut)
        use_mock = os.getenv("PAYMENTS_USE_MOCK", "TRUE").upper() == "TRUE"

        self.adapters = {
            "mock": MockAdapter(),
            "orange": OrangeAdapter() if not use_mock else MockAdapter(),
            "mtn": MTNAdapter() if not use_mock else MockAdapter(),
            "paypal": PayPalAdapter() if not use_mock else MockAdapter(),
            "visa": VisaAdapter() if not use_mock else MockAdapter(),
        }

        self.default_method = "mock"

    # ============================================================================
    # 1️⃣ CRÉATION D’UN PAIEMENT (ORANGE, MTN, VISA, PAYPAL…)
    # ============================================================================
    def create_payment(self, user_id: int, plan_id: int, method: str):
        with SessionLocal() as db:

            # Vérifier que le plan existe
            plan = db.query(Plan).filter(Plan.id == plan_id).first()
            if not plan:
                return {"status": "ERROR", "message": "Plan introuvable"}

            # Sélectionner l’adapteur PSP
            m = (method or self.default_method).lower()
            adapter = self.adapters.get(m, self.adapters[self.default_method])

            # Générer une référence unique
            reference = str(uuid.uuid4())

            # Créer le paiement dans la base
            payment = Payment(
                user_id=user_id,
                method=m,
                plan=plan.name,
                amount=plan.price,
                currency="GNF",
                status="pending",
                reference=reference,
                created_at=datetime.utcnow(),
            )

            db.add(payment)
            db.commit()
            db.refresh(payment)

            # Appel API vers l’adapteur (Mock / Orange / MTN / Visa / PayPal)
            psp_result = adapter.create_payment(
                amount=plan.price,
                currency="GNF",
                metadata={"plan_id": plan_id, "payment_id": payment.id}
            )

            return {
                "status": "PENDING",
                "payment_id": payment.id,
                "reference": reference,
                "gateway": m,
                "redirect_url": psp_result.get("redirect_url"),
                "message": "Paiement en attente de confirmation"
            }

    # ============================================================================
    # 2️⃣ CONFIRMATION DU PAYMENT (WEBHOOK / CALLBACK)
    # ============================================================================
    def confirm_payment(self, payment_id: int):
        with SessionLocal() as db:

            payment = db.query(Payment).filter(Payment.id == payment_id).first()
            if not payment:
                return {"status": "NOT_FOUND", "message": "Identifiant introuvable"}

            # Appeler tous les PSP pour vérifier la transaction
            for name, adapter in self.adapters.items():
                result = adapter.confirm_payment(str(payment_id))

                if result.get("status") == "SUCCESS":
                    payment.status = "success"
                    payment.provider_transaction_id = result.get("provider_txn")
                    db.commit()
                    return {"status": "SUCCESS", "message": "Paiement validé"}

                if result.get("status") == "FAILED":
                    payment.status = "failed"
                    db.commit()
                    return {"status": "FAILED", "message": "Paiement refusé"}

            return {"status": "PENDING", "message": "Confirmation en attente"}
