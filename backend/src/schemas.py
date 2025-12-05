from datetime import datetime
from pydantic import BaseModel, validator
from typing import Optional, List


# ===============================================================
# USERS
# ===============================================================
class UserBase(BaseModel):
    first_name: str
    last_name: str
    phone_number: str
    email: Optional[str] = None  # 📧 Email optionnel
    country: str
    isBusiness: bool = False
    company_name: Optional[str] = None
    max_devices_allowed: Optional[int] = 1
    avatar: Optional[str] = None


class UserIn(UserBase):
    """PAS utilisé par register() car register est multipart"""
    password: str


class UserLogin(BaseModel):
    """
    Login unifié - accepte identifier (email OU téléphone) + password
    Compatible avec: "620035847", "+224620035847", "user@gmail.com"
    """
    identifier: Optional[str] = None  # 🔥 Nouveau champ unifié
    phone: Optional[str] = None       # Rétrocompatibilité
    phone_number: Optional[str] = None  # Rétrocompatibilité
    password: str

    @validator('identifier', pre=True, always=True)
    def set_identifier(cls, v, values):
        # Priorité: identifier > phone_number > phone
        return v or values.get('phone_number') or values.get('phone')

    def get_identifier(self) -> str:
        """Retourne l'identifiant (email ou téléphone)"""
        return self.identifier or self.phone_number or self.phone or ""
    
    def is_email(self) -> bool:
        """Vérifie si l'identifiant est un email"""
        ident = self.get_identifier()
        return '@' in ident and '.' in ident


class UserOut(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True  # Pydantic v2
        orm_mode = True         # Compatibilité Pydantic v1


# ===============================================================
# REGISTER REQUEST (JSON - pour Flutter)
# ===============================================================
class RegisterRequest(BaseModel):
    """Schéma pour inscription via JSON (Flutter)"""
    first_name: str
    last_name: str
    phone_number: str
    country: str
    password: str
    isBusiness: bool = False
    avatar: Optional[str] = None


# ===============================================================
# LOGIN RESPONSE (avec données utilisateur pour Flutter)
# ===============================================================
class LoginResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserOut


# ===============================================================
# REGISTER RESPONSE (avec token + user pour Flutter)
# ===============================================================
class RegisterResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserOut


# ===============================================================
# TOKEN (Access + Refresh)
# ===============================================================
class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


# ===============================================================
# PASSWORD RESET
# ===============================================================
class ForgotPassword(BaseModel):
    phone: str


class ResetPassword(BaseModel):
    phone: Optional[str] = None
    code: str
    new_password: str


# ===============================================================
# PLANS
# ===============================================================
class PlanBase(BaseModel):
    name: str
    price: int
    duration_minutes: int
    isBusiness: bool = False
    max_devices: Optional[int] = 1


class PlanCreate(PlanBase):
    pass


class PlanOut(PlanBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True
        orm_mode = True


# ===============================================================
# SUBSCRIPTIONS
# ===============================================================
class SubscriptionOut(BaseModel):
    id: int
    start_at: datetime
    end_at: datetime
    is_active: bool
    auto_renew: bool
    voucher_code: Optional[str] = None
    plan: Optional[PlanOut] = None

    class Config:
        from_attributes = True
        orm_mode = True


# ===============================================================
# VOUCHERS
# ===============================================================
class VoucherBase(BaseModel):
    type: str
    duration_minutes: int
    max_devices: int = 1


class VoucherCreate(VoucherBase):
    pass


class VoucherOut(VoucherBase):
    id: int
    code: str
    is_used: bool
    used_by: Optional[int]
    created_at: datetime
    qr_data: Optional[str]
    used_at: Optional[datetime]

    class Config:
        from_attributes = True
        orm_mode = True


class VoucherUseRequest(BaseModel):
    code: str


class VoucherUseResponse(BaseModel):
    success: bool
    expires: datetime
    message: Optional[str] = None


# ===============================================================
# PAYMENTS
# ===============================================================
class PaymentOut(BaseModel):
    id: int
    user_id: int
    method: str
    plan: Optional[str]
    amount: int
    currency: str
    status: str
    reference: Optional[str]
    provider_transaction_id: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
        orm_mode = True


# ===============================================================
# WIFI ACCESS
# ===============================================================
class WifiAccessOut(BaseModel):
    id: int
    user_id: int
    active: bool
    start_date: datetime
    end_date: datetime
    last_ip: Optional[str]
    last_device_identifier: Optional[str]
    updated_at: datetime

    class Config:
        from_attributes = True
        orm_mode = True


# ===============================================================
# DEVICE (multi-appareils)
# ===============================================================
class DeviceOut(BaseModel):
    id: int
    user_id: int
    identifier: Optional[str]
    user_agent: Optional[str]
    ip: Optional[str]
    is_blocked: bool
    last_seen: datetime

    class Config:
        from_attributes = True
        orm_mode = True


# ===============================================================
# CONNECTION HISTORY
# ===============================================================
class ConnectionHistoryOut(BaseModel):
    id: int
    user_id: int
    device_id: Optional[int]
    ip: Optional[str]
    user_agent: Optional[str]
    voucher_code: Optional[str]
    start_at: datetime
    end_at: Optional[datetime]
    success: bool
    note: Optional[str]

    class Config:
        from_attributes = True
        orm_mode = True


# ===============================================================
# ADMIN DASHBOARD — VERSION PRO (COMPATIBLE admin.py)
# ===============================================================
class AdminStats(BaseModel):
    users: int
    subscriptions: dict
    devices: int
    connections: dict
    wifi: dict
    vouchers: dict
    revenue: dict
