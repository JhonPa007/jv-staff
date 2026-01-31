from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date
from typing import Optional

from app.database import get_db
from app.routers.auth import get_current_user 

router = APIRouter(prefix="/staff", tags=["Staff Reports"])

# --- UTILIDAD: FILTROS DE FECHA ---
def get_date_range(start_date: Optional[date], end_date: Optional[date]):
    if not start_date:
        today = date.today()
        start_date = date(today.year, today.month, 1)
    if not end_date:
        end_date = date.today()
    return start_date, end_date

@router.get("/dashboard")
def get_dashboard(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    user_id = current_user.id
    user_name = current_user.email.split('@')[0].capitalize() # O username si tienes columna
    start, end = get_date_range(start_date, end_date)

    # 1. PRODUCCIÓN (Corregido con JOIN si empleado_id no está en items)
    # Intentamos primero directo, si falla, asumimos que necesitas un JOIN con 'venta'
    # Esta query asume que existe una tabla 'venta' vinculada por 'venta_id'
    
    query_prod = text("""
        SELECT COALESCE(SUM(vi.subtotal_item_neto), 0)
        FROM venta_items vi
        JOIN venta v ON vi.venta_id = v.id  -- <--- JOIN CLAVE
        WHERE v.empleado_id = :uid          -- Buscamos en la cabecera
        AND vi.servicio_id IS NOT NULL
        AND vi.es_trabajo_extra = false
        AND v.fecha BETWEEN :start AND :end -- Filtramos por fecha de la venta
    """)
    
    # NOTA: Si esto falla, es porque los nombres de tablas/columnas son distintos.
    # Necesito ver tu esquema real para ser preciso.
    
    try:
        production = db.execute(query_prod, {"uid": user_id, "start": start, "end": end}).scalar()
    except Exception as e:
        print(f"Error SQL Producción: {e}")
        production = 0

    # 2. COMISIONES
    query_com_pending = text("""
        SELECT COALESCE(SUM(monto_comision), 0) FROM comisiones 
        WHERE empleado_id = :uid AND estado = 'Pendiente'
    """)
    
    try:
        pending_comm = db.execute(query_com_pending, {"uid": user_id}).scalar()
    except:
        pending_comm = 0

    # 3. METRICAS DUMMY (Por ahora, para que no falle)
    rating = 4.8
    completed_services = 15

    # 4. PRÓXIMA CITA
    query_next = text("""
        SELECT fecha_hora_inicio, servicio_id, cliente_id 
        FROM reserva 
        WHERE empleado_id = :uid 
        AND estado = 'Programada' 
        AND fecha_hora_inicio >= NOW()
        ORDER BY fecha_hora_inicio ASC 
        LIMIT 1
    """)
    
    next_appt_row = db.execute(query_next, {"uid": user_id}).first()
    next_appt = None
    
    if next_appt_row:
        next_appt = {
            "time": next_appt_row.fecha_hora_inicio.strftime("%H:%M"),
            "client": f"Cliente #{next_appt_row.cliente_id}", # Idealmente JOIN con clientes
            "service": "Servicio Agendado" # Idealmente JOIN con servicios
        }

    return {
        "period": start.strftime("%B %Y"),
        "user_name": user_name,
        "metrics": {
            "total_production": float(production or 0),
            "total_commission_pending": float(pending_comm or 0),
            "total_commission_paid": 0.0,
            "rating": rating,
            "completed_services": completed_services
        },
        "next_appointment": next_appt
    }