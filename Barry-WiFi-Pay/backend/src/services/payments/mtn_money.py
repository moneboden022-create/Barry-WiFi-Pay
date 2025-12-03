# backend/src/services/payments/mtn_money.py
import uuid
import random

class MTNMoneyAPI:
    def __init__(self, real_mode=False):
        self.real_mode = real_mode

    def init_payment(self, phone, amount):
        ref = str(uuid.uuid4())

        if not self.real_mode:
            return {
                "status": "PENDING",
                "reference": ref,
                "message": "Mock MTN payment created"
            }

        raise NotImplementedError("MTN MoMo real API not configured.")

    def check_status(self, reference):
        if not self.real_mode:
            return {
                "reference": reference,
                "status": random.choice(["SUCCESS", "FAILED"])
            }

        raise NotImplementedError("MTN real API not implemented yet.")
