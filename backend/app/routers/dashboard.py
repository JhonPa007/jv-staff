from fastapi import APIRouter
from ..models.schemas import DashboardResponse, DashboardMetrics, NextAppointment

router = APIRouter(
    prefix="/staff",
    tags=["Staff"]
)

@router.get("/dashboard", response_model=DashboardResponse)
async def get_dashboard():
    # Mock Data
    return DashboardResponse(
        period="Enero 2024",
        metrics=DashboardMetrics(
            total_production=1500.00,
            total_commission_paid=400.00,
            total_commission_pending=120.00,
            appointments_completed=45,
            average_rating=4.8
        ),
        next_appointment=NextAppointment(
            client_name="Carlos Perez",
            service="Corte + Barba",
            time="14:30"
        )
    )

@router.post("/upload-evidence")
async def upload_evidence():
    # Mock upload endpoint
    return {"message": "Evidence uploaded successfully"}
