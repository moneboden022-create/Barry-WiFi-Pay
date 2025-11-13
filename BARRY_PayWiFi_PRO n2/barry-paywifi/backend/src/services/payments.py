import os, uuid
from src.services.payments.adapters import (
    MockAdapter, OrangeAdapter, MTNAdapter, PayPalAdapter, VisaAdapter
)

class PaymentsService:
    def __init__(self):
        use_mock = os.getenv("PAYMENTS_USE_MOCK", "TRUE").upper() == "TRUE"
        self.adapters = {
            "mock": MockAdapter(),
            "orange": OrangeAdapter() if not use_mock else MockAdapter(),
            "mtn": MTNAdapter() if not use_mock else MockAdapter(),
            "paypal": PayPalAdapter() if not use_mock else MockAdapter(),
            "visa": VisaAdapter() if not use_mock else MockAdapter(),
        }
        self.default_method = "mock"

    def create_payment(self, amount: float, currency: str, plan_id: str, method: str | None):
        m = (method or self.default_method).lower()
        adapter = self.adapters.get(m, self.adapters[self.default_method])
        return adapter.create_payment(amount=amount, currency=currency, metadata={"plan_id": plan_id})

    def confirm_payment(self, payment_id: str):
        # Dans un vrai flow : vérifier chez le PSP + sécurité (signatures)
        for a in self.adapters.values():
            res = a.confirm_payment(payment_id)
            if res.get("status"):
                return res
        return {"status": "NOT_FOUND", "payment_id": payment_id}
