from pydantic import BaseModel, ConfigDict
from enum import Enum
from typing import List, Optional

# --- Auth Schemas ---
class Token(BaseModel):
    access_token: str
    token_type: str

class UserBase(BaseModel):
    id: int
    name: str
    role: str
    photo_url: str

class UserLogin(BaseModel):
    email: str
    password: str

class LoginResponse(BaseModel):
    token: str
    user: UserBase

# --- Dashboard Schemas ---
class DashboardMetrics(BaseModel):
    total_production: float
    total_commission_paid: float
    total_commission_pending: float
    appointments_completed: int
    average_rating: float

class NextAppointment(BaseModel):
    client_name: str
    service: str
    time: str

class DashboardResponse(BaseModel):
    period: str
    metrics: DashboardMetrics
    next_appointment: Optional[NextAppointment]

# --- Appointment Schemas ---
class AppointmentBase(BaseModel):
    id: int
    client_name: str
    service_list: List[str]
    start_time: str # ISO format
    status: str
    is_vip: bool

class AppointmentFinishRequest(BaseModel):
    evidence_url: str

class AppointmentFinishResponse(BaseModel):
    status: str
    earned_amount: float
    new_balance: float

    model_config = ConfigDict(from_attributes=True)

# --- Commission Schemas ---
class PaymentStatus(str, Enum):
    PENDING = "PENDING"
    PAID = "PAID"

class CommissionItem(BaseModel):
    id: int
    service_name: str
    client_name: str
    date: str
    service_amount: float
    commission_rate: float
    earned_amount: float
    status: PaymentStatus

class CommissionResponse(BaseModel):
    earned: float
    paid: float
    pending: float
    transactions: List[CommissionItem]
