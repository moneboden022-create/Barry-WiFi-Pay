from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Float, Enum
)
from sqlalchemy.orm import relationship
from .db import Base
import enum


# ============================================================
# 🔐 ENUMS
# ============================================================
class VoucherType(str, enum.Enum):
    INDIVIDUAL = "individual"
    BUSINESS = "business"
    ENTERPRISE = "enterprise"
    VIP = "vip"


class AdminRole(str, enum.Enum):
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    MODERATOR = "moderator"


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
    admin_role = Column(String, nullable=True)  # super_admin, admin, moderator

    # Géolocalisation (opt-in)
    geo_enabled = Column(Boolean, default=False)
    last_latitude = Column(Float, nullable=True)
    last_longitude = Column(Float, nullable=True)
    last_geo_update = Column(DateTime, nullable=True)

    # Sécurité
    failed_login_attempts = Column(Integer, default=0)
    locked_until = Column(DateTime, nullable=True)
    last_login_at = Column(DateTime, nullable=True)
    last_login_ip = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)

    # Relations
    subscriptions = relationship("Subscription", back_populates="user", cascade="all, delete-orphan")
    devices = relationship("Device", back_populates="user", cascade="all, delete-orphan")
    payments = relationship("Payment", back_populates="user", cascade="all, delete-orphan")
    wifi_accesses = relationship("WifiAccess", back_populates="user", cascade="all, delete-orphan")
    histories = relationship("ConnectionHistory", back_populates="user", cascade="all, delete-orphan")
    geolocations = relationship("UserGeolocation", back_populates="user", cascade="all, delete-orphan")


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
    
    # 📱 Informations détaillées de l'appareil
    device_name = Column(String, nullable=True)
    device_model = Column(String, nullable=True)
    device_type = Column(String, nullable=True)  # mobile, tablet, desktop
    os_name = Column(String, nullable=True)
    os_version = Column(String, nullable=True)
    
    # 🔗 Adresse MAC
    mac_address = Column(String(17), nullable=True, index=True)
    
    # 🌍 Géolocalisation du device
    last_latitude = Column(Float, nullable=True)
    last_longitude = Column(Float, nullable=True)

    is_blocked = Column(Boolean, default=False)
    block_reason = Column(String, nullable=True)
    blocked_at = Column(DateTime, nullable=True)
    blocked_by = Column(Integer, nullable=True)  # admin_id
    
    is_trusted = Column(Boolean, default=False)
    
    first_seen = Column(DateTime, default=datetime.utcnow)
    last_seen = Column(DateTime, default=datetime.utcnow)
    
    # Compteur de sessions
    total_sessions = Column(Integer, default=0)
    total_data_mb = Column(Float, default=0.0)

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
    mac_address = Column(String(17), nullable=True)

    start_at = Column(DateTime, default=datetime.utcnow)
    end_at = Column(DateTime, nullable=True)
    
    # Données de session
    duration_minutes = Column(Integer, nullable=True)
    data_used_mb = Column(Float, nullable=True)
    
    # Géolocalisation
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    location_name = Column(String, nullable=True)

    success = Column(Boolean, default=True)
    note = Column(String, nullable=True)
    
    # Type de déconnexion
    disconnect_reason = Column(String, nullable=True)  # manual, expired, kicked, error

    user = relationship("User", back_populates="histories")


# ============================================================
# 🌍 USER GEOLOCATION (Historique positions - opt-in RGPD)
# ============================================================
class UserGeolocation(Base):
    __tablename__ = "user_geolocations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    accuracy = Column(Float, nullable=True)  # Précision en mètres
    
    # Informations de localisation
    city = Column(String, nullable=True)
    region = Column(String, nullable=True)
    country = Column(String, nullable=True)
    country_code = Column(String(2), nullable=True)
    
    # Contexte
    device_id = Column(Integer, ForeignKey("devices.id"), nullable=True)
    connection_id = Column(Integer, nullable=True)
    
    recorded_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="geolocations")


# ============================================================
# 🚫 BLOCKED ZONES (Zones WiFi autorisées/interdites)
# ============================================================
class BlockedZone(Base):
    __tablename__ = "blocked_zones"

    id = Column(Integer, primary_key=True, index=True)
    
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    
    # Type de zone
    zone_type = Column(String, nullable=False)  # allow, deny
    scope = Column(String, nullable=False)  # wifi_network, city, region, country
    
    # Coordonnées (pour zone géographique)
    center_latitude = Column(Float, nullable=True)
    center_longitude = Column(Float, nullable=True)
    radius_km = Column(Float, nullable=True)
    
    # Identifiants réseau (pour zone WiFi)
    ssid = Column(String, nullable=True)
    bssid = Column(String, nullable=True)
    
    # Identifiants géographiques
    country_code = Column(String(2), nullable=True)
    region_code = Column(String, nullable=True)
    city_name = Column(String, nullable=True)
    
    is_active = Column(Boolean, default=True)
    created_by = Column(Integer, nullable=True)  # admin_id
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# 📝 ADMIN LOGS (Logs administratifs)
# ============================================================
class AdminLog(Base):
    __tablename__ = "admin_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    
    level = Column(String(20), default="INFO")
    category = Column(String(30), default="SYSTEM")
    
    action = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    
    user_id = Column(Integer, nullable=True, index=True)
    admin_id = Column(Integer, nullable=True, index=True)
    
    ip_address = Column(String(45), nullable=True)
    ip_hash = Column(String(64), nullable=True)
    user_agent = Column(String(500), nullable=True)
    
    request_path = Column(String(255), nullable=True)
    request_method = Column(String(10), nullable=True)
    
    extra_data = Column(Text, nullable=True)
    
    target_type = Column(String(50), nullable=True)
    target_id = Column(Integer, nullable=True)


# ============================================================
# 📊 DAILY STATISTICS (Stats agrégées par jour)
# ============================================================
class DailyStatistics(Base):
    __tablename__ = "daily_statistics"
    
    id = Column(Integer, primary_key=True, index=True)
    date = Column(DateTime, nullable=False, unique=True, index=True)
    
    # Utilisateurs
    total_users = Column(Integer, default=0)
    new_users = Column(Integer, default=0)
    active_users = Column(Integer, default=0)
    
    # Connexions
    total_connections = Column(Integer, default=0)
    successful_connections = Column(Integer, default=0)
    failed_connections = Column(Integer, default=0)
    
    # Vouchers
    vouchers_created = Column(Integer, default=0)
    vouchers_used = Column(Integer, default=0)
    vouchers_expired = Column(Integer, default=0)
    
    # Revenus
    total_revenue = Column(Float, default=0.0)
    currency = Column(String(3), default="GNF")
    
    # Appareils
    unique_devices = Column(Integer, default=0)
    blocked_devices = Column(Integer, default=0)
    
    # Données
    total_data_mb = Column(Float, default=0.0)
    peak_hour = Column(Integer, nullable=True)  # Heure de pointe (0-23)
    peak_connections = Column(Integer, default=0)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# 🏢 ENTERPRISE (Comptes entreprise PRO)
# ============================================================
class Enterprise(Base):
    __tablename__ = "enterprises"
    
    id = Column(Integer, primary_key=True, index=True)
    
    name = Column(String, nullable=False)
    legal_name = Column(String, nullable=True)
    registration_number = Column(String, nullable=True)
    
    # Contact
    email = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    address = Column(Text, nullable=True)
    city = Column(String, nullable=True)
    country = Column(String, nullable=True)
    
    # Limites
    max_users = Column(Integer, default=10)
    max_devices_per_user = Column(Integer, default=3)
    max_total_devices = Column(Integer, default=30)
    
    # Abonnement entreprise
    subscription_type = Column(String, nullable=True)  # basic, pro, enterprise
    subscription_start = Column(DateTime, nullable=True)
    subscription_end = Column(DateTime, nullable=True)
    
    # Admin entreprise (propriétaire)
    owner_user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)


# ============================================================
# 🔗 ENTERPRISE MEMBERS (Membres d'une entreprise)
# ============================================================
class EnterpriseMember(Base):
    __tablename__ = "enterprise_members"
    
    id = Column(Integer, primary_key=True, index=True)
    enterprise_id = Column(Integer, ForeignKey("enterprises.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    role = Column(String, default="member")  # owner, admin, member
    department = Column(String, nullable=True)
    
    # Limites personnalisées (override enterprise defaults)
    custom_device_limit = Column(Integer, nullable=True)
    
    is_active = Column(Boolean, default=True)
    joined_at = Column(DateTime, default=datetime.utcnow)
