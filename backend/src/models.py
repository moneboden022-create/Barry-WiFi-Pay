from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, ForeignKey, Text
)
from sqlalchemy.orm import relationship
from .db import Base


# ============================================================
# 👤 USERS
# ============================================================
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    phone_number = Column(String, unique=True, index=True, nullable=False)
    country = Column(String, nullable=False)

    # PRO / BUSINESS
    isBusiness = Column(Boolean, default=False)
    company_name = Column(String, nullable=True)

    # 📸 AVATAR (URL)
    avatar = Column(String, nullable=True)

    # Limite d'appareils dynamique (modifié par plan ou voucher)
    max_devices_allowed = Column(Integer, default=1)

    # Auth
    hashed_password = Column(String, nullable=False)
    reset_code = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)

    # Admin Dashboard
    is_admin = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)

    # Relations
    subscriptions = relationship("Subscription", back_populates="user", cascade="all, delete-orphan")
    devices = relationship("Device", back_populates="user", cascade="all, delete-orphan")
    payments = relationship("Payment", back_populates="user", cascade="all, delete-orphan")
    wifi_accesses = relationship("WifiAccess", back_populates="user", cascade="all, delete-orphan")
    histories = relationship("ConnectionHistory", back_populates="user", cascade="all, delete-orphan")


# ============================================================
# 📦 PLANS (FORFAITS)
# ============================================================
class Plan(Base):
    __tablename__ = "plans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    price = Column(Integer, nullable=False)
    duration_minutes = Column(Integer, nullable=False)

    isBusiness = Column(Boolean, default=False)
    max_devices = Column(Integer, default=1)

    created_at = Column(DateTime, default=datetime.utcnow)

    subscriptions = relationship("Subscription", back_populates="plan")


# ============================================================
# 🎟️ VOUCHERS
# ============================================================
class Voucher(Base):
    __tablename__ = "vouchers"

    id = Column(Integer, primary_key=True, index=True)
    code = Column(String, unique=True, index=True, nullable=False)

    type = Column(String, nullable=False)        # individual / business
    duration_minutes = Column(Integer, nullable=False)
    max_devices = Column(Integer, default=1)

    is_used = Column(Boolean, default=False)
    used_by = Column(Integer, ForeignKey("users.id"), nullable=True)

    qr_data = Column(Text, nullable=True)
    used_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# 🔐 SUBSCRIPTIONS
# ============================================================
class Subscription(Base):
    __tablename__ = "subscriptions"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    plan_id = Column(Integer, ForeignKey("plans.id"), nullable=True)
    voucher_code = Column(String, nullable=True)

    start_at = Column(DateTime, nullable=False)
    end_at = Column(DateTime, nullable=False)

    is_active = Column(Boolean, default=True)
    auto_renew = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="subscriptions")
    plan = relationship("Plan", back_populates="subscriptions")


# ============================================================
# 💰 PAYMENTS
# ============================================================
class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    method = Column(String, nullable=False)
    plan = Column(String, nullable=True)
    amount = Column(Integer, nullable=False)
    currency = Column(String, default="GNF")
    status = Column(String, default="pending")

    reference = Column(String, nullable=True, index=True)
    provider_transaction_id = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="payments")


# ============================================================
# 📶 WIFI ACCESS
# ============================================================
class WifiAccess(Base):
    __tablename__ = "wifi_accesses"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    active = Column(Boolean, default=True)
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)

    last_ip = Column(String, nullable=True)
    last_device_identifier = Column(String, nullable=True)

    updated_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="wifi_accesses")


# ============================================================
# 📱 DEVICE
# ============================================================
class Device(Base):
    __tablename__ = "devices"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    user_agent = Column(String, nullable=True)
    ip = Column(String, nullable=True)

    identifier = Column(String, nullable=False)  # UNIQUE ID PER APPAREIL

    is_blocked = Column(Boolean, default=False)
    last_seen = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="devices")


# ============================================================
# 📊 CONNECTION HISTORY
# ============================================================
class ConnectionHistory(Base):
    __tablename__ = "connection_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    voucher_code = Column(String, nullable=True)
    device_id = Column(Integer, ForeignKey("devices.id"), nullable=True)

    ip = Column(String, nullable=True)
    user_agent = Column(String, nullable=True)

    start_at = Column(DateTime, default=datetime.utcnow)
    end_at = Column(DateTime, nullable=True)

    success = Column(Boolean, default=True)
    note = Column(String, nullable=True)

    user = relationship("User", back_populates="histories")
