from datetime import datetime
from pydantic import BaseModel
from typing import Optional, List


# ===============================================================
# USERS
# ===============================================================
class UserBase(BaseModel):
    first_name: str
    last_name: str
    phone_number: str
    country: str
    isBusiness: bool = False
    company_name: Optional[str] = None
    max_devices_allowed: Optional[int] = 1
    avatar: Optional[str] = None


class UserIn(UserBase):
    """PAS utilisé par register() car register est multipart"""
    password: str


class UserLogin(BaseModel):
    phone_number: str
    password: str


class UserOut(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True


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
    phone: str
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
        orm_mode = True


class VoucherUseRequest(BaseModel):
    code: str


class VoucherUseResponse(BaseModel):
    success: bool
    expires: datetime


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
