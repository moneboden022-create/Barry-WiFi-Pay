# backend/src/services/payments/mobile_money.py
from .orange_money import OrangeMoneyAPI
from .mtn_money import MTNMoneyAPI

class MobileMoneyService:
    def __init__(self, real_mode=False):
        self.om = OrangeMoneyAPI(real_mode)
        self.mtn = MTNMoneyAPI(real_mode)

    def start_payment(self, operator, phone, amount):
        if operator == "orange":
            return self.om.init_payment(phone, amount)
        elif operator == "mtn":
            return self.mtn.init_payment(phone, amount)
        else:
            raise ValueError("Operator must be orange or mtn")

    def verify(self, operator, reference):
        if operator == "orange":
            return self.om.check_status(reference)
        elif operator == "mtn":
            return self.mtn.check_status(reference)
        else:
            raise ValueError("Invalid operator")
