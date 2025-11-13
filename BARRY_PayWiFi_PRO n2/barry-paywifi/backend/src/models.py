from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Float, Boolean
from src.db import Base

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    payment_id = Column(String(64), index=True, unique=True)
    user_id = Column(String(128), index=True)
    method = Column(String(32))
    plan = Column(String(16))          # instant | daily | monthly | yearly
    amount = Column(Float)
    currency = Column(String(8), default="GNF")
    status = Column(String(16))        # SUCCESS | FAILED | PENDING
    created_at = Column(DateTime, default=datetime.utcnow)

class WifiAccess(Base):
    __tablename__ = "wifi_access"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(128), index=True, unique=True)
    active = Column(Boolean, default=False)
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    updated_at = Column(DateTime, default=datetime.utcnow)
