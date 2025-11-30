import uuid
from datetime import datetime, timedelta
from sqlalchemy import select, update
from src.db import SessionLocal, Base, engine
from src.models import Payment, WifiAccess
from src.services.network.providers import WifiNetworkManager

# -------------------------------------------------------
# Initialisation de la base de données
# -------------------------------------------------------
try:
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print("⚠️ DB init error:", e)


# -------------------------------------------------------
# Classe de base pour les adaptateurs de paiement
# -------------------------------------------------------
class BaseAdapter:
    def create_payment(self, amount: float, currency: str, metadata: dict):
        raise NotImplementedError

    def confirm_payment(self, payment_id: str):
        raise NotImplementedError


# -------------------------------------------------------
# Mock (Simulation)
# -------------------------------------------------------
class MockAdapter(BaseAdapter):
    def __init__(self):
        self.store = {}

    def create_payment(self, amount: float, currency: str, metadata: dict):
        pid = str(uuid.uuid4().hex[:8])
        self.store[pid] = {"amount": amount, "currency": currency, "metadata": metadata, "status": "SUCCESS"}
        return {"payment_id": pid, "status": "SUCCESS"}

    def confirm_payment(self, payment_id: str):
        return {"status": "SUCCESS", "payment_id": payment_id}


# -------------------------------------------------------
# Orange Money
# -------------------------------------------------------
class OrangeMoneyAdapter(BaseAdapter):
    def create_payment(self, amount: float, currency: str, metadata: dict):
        pid = str(uuid.uuid4().hex[:8])
        return {"payment_id": pid, "status": "PENDING", "amount": amount, "currency": currency, "metadata": metadata}

    def confirm_payment(self, payment_id: str):
        return {"status": "SUCCESS", "payment_id": payment_id}


# -------------------------------------------------------
# MTN Money
# -------------------------------------------------------
class MTNAdapter(BaseAdapter):
    def create_payment(self, amount: float, currency: str, metadata: dict):
        pid = str(uuid.uuid4().hex[:8])
        return {"payment_id": pid, "status": "PENDING", "amount": amount, "currency": currency, "metadata": metadata}

    def confirm_payment(self, payment_id: str):
        return {"status": "SUCCESS", "payment_id": payment_id}


# -------------------------------------------------------
# PayPal
# -------------------------------------------------------
class PayPalAdapter(BaseAdapter):
    def create_payment(self, amount: float, currency: str, metadata: dict):
        pid = str(uuid.uuid4().hex[:8])
        return {"payment_id": pid, "status": "PENDING", "amount": amount, "currency": currency, "metadata": metadata}

    def confirm_payment(self, payment_id: str):
        return {"status": "SUCCESS", "payment_id": payment_id}


# -------------------------------------------------------
# Visa
# -------------------------------------------------------
class VisaAdapter(BaseAdapter):
    def create_payment(self, amount: float, currency: str, metadata: dict):
        pid = str(uuid.uuid4().hex[:8])
        return {"payment_id": pid, "status": "PENDING", "amount": amount, "currency": currency, "metadata": metadata}

    def confirm_payment(self, payment_id: str):
        return {"status": "SUCCESS", "payment_id": payment_id}


# -------------------------------------------------------
# Service principal : gestion centrale des paiements + Wi-Fi
# -------------------------------------------------------
class PaymentService:
    def __init__(self):
        print("✅ PaymentService initialisé")
        self.adapters = {
            "orange_money": OrangeMoneyAdapter(),
            "mtn_money": MTNAdapter(),
            "paypal": PayPalAdapter(),
            "visa": VisaAdapter(),
            "mock": MockAdapter(),
        }
        self.wifi_manager = WifiNetworkManager()  # 🔌 Connexion Wi-Fi

    def process_payment(self, user_id: str, amount: float, method: str, plan: str = "instant"):
        adapter = self.adapters.get(method)
        if not adapter:
            return {"status": "ERROR", "message": f"Méthode '{method}' non supportée"}

        metadata = {"user_id": user_id, "plan": plan}
        payment = adapter.create_payment(amount, "GNF", metadata)
        confirmation = adapter.confirm_payment(payment["payment_id"])

        with SessionLocal() as db:
            pay_row = Payment(
                payment_id=payment["payment_id"],
                user_id=user_id,
                method=method,
                plan=plan,
                amount=amount,
                currency="GNF",
                status=confirmation["status"],
            )
            db.add(pay_row)

            if confirmation["status"] == "SUCCESS":
                start_date = datetime.utcnow()

                if plan == "daily":
                    end_date = start_date + timedelta(days=1)
                    duration = 1
                elif plan == "monthly":
                    end_date = start_date + timedelta(days=30)
                    duration = 30
                elif plan == "yearly":
                    end_date = start_date + timedelta(days=365)
                    duration = 365
                else:
                    end_date = start_date
                    duration = 0

                wifi_status = self.wifi_manager.activate_wifi(user_id, duration)

                existing = db.execute(select(WifiAccess).where(WifiAccess.user_id == user_id)).scalar_one_or_none()
                if existing:
                    existing.active = True
                    existing.start_date = start_date
                    existing.end_date = end_date
                else:
                    db.add(WifiAccess(
                        user_id=user_id,
                        active=True,
                        start_date=start_date,
                        end_date=end_date
                    ))
                db.commit()

                print(f"✅ Paiement confirmé pour {user_id} ({plan.upper()} - {method})")
                return {
                    "status": "SUCCESS",
                    "payment_id": payment["payment_id"],
                    "plan": plan,
                    "method": method,
                    "wifi": wifi_status,
                    "start_date": str(start_date),
                    "end_date": str(end_date),
                }

            db.commit()
            return {"status": "FAILED", "payment_id": payment["payment_id"], "method": method}