from fastapi import APIRouter
from app.internal_db import db

router = APIRouter(prefix="/staff", tags=["Staff"])

@router.get("/dashboard")
def get_dashboard():
    return {
        "period": "Enero 2024",
        "metrics": {
            "total_production": db.total_production,
            "total_commission_pending": db.pending_commission,
            "rating": 4.8,
            "completed_services": db.appointments_completed
        }
    }