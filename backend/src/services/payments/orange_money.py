# backend/src/services/payments/orange_money.py
import uuid
import random

class OrangeMoneyAPI:
    def __init__(self, real_mode=False):
        self.real_mode = real_mode

    def init_payment(self, phone, amount):
        """
        real_mode=False  => mode test (réponse auto)
        real_mode=True   => vrai appel API OM
        """
        ref = str(uuid.uuid4())

        if not self.real_mode:
            return {
                "status": "PENDING",
                "reference": ref,
                "message": "Mock OM payment created"
            }

        # Ici plus tard : appel réel à Orange Money API
        raise NotImplementedError("Orange Money API real mode not configured.")

    def check_status(self, reference):
        if not self.real_mode:
            return {
                "reference": reference,
                "status": random.choice(["SUCCESS", "FAILED"])
            }

        raise NotImplementedError("OM real API not implemented yet.")
