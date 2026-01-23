from fastapi import APIRouter
from typing import List
from ..models.schemas import CommissionResponse, CommissionItem, PaymentStatus

router = APIRouter(
    prefix="/commissions",
    tags=["Commissions"]
)

@router.get("/my-summary", response_model=CommissionResponse)
async def get_my_summary():
    # Mock Data
    transactions = [
        CommissionItem(
            id=101,
            service_name="Corte Clásico",
            client_name="Mario Vargas",
            date="2024-01-20T10:00:00",
            service_amount=50.00,
            commission_rate=0.40,  # 40%
            earned_amount=20.00,
            status=PaymentStatus.PAID
        ),
        CommissionItem(
            id=102,
            service_name="Barba + Toalla",
            client_name="Pedro Suarez",
            date="2024-01-21T15:30:00",
            service_amount=30.00,
            commission_rate=0.40,
            earned_amount=12.00,
            status=PaymentStatus.PENDING
        ),
        CommissionItem(
            id=103,
            service_name="Tinte Cabello",
            client_name="Luis Fonsi",
            date="2024-01-22T11:00:00",
            service_amount=100.00,
            commission_rate=0.50, # 50%
            earned_amount=50.00,
            status=PaymentStatus.PENDING
        )
    ]

    total_earned = sum(t.earned_amount for t in transactions)
    total_paid = sum(t.earned_amount for t in transactions if t.status == PaymentStatus.PAID)
    total_pending = sum(t.earned_amount for t in transactions if t.status == PaymentStatus.PENDING)

    return CommissionResponse(
        earned=total_earned,
        paid=total_paid,
        pending=total_pending,
        transactions=transactions
    )
