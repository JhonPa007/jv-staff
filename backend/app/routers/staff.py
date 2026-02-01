from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date
from typing import Optional

from app.database import get_db
from app.routers.auth import get_current_user 

router = APIRouter(prefix="/staff", tags=["Staff Reports"])

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
    user_name = current_user.email.split('@')[0].capitalize()
    
    start, end = get_date_range(start_date, end_date)

    # 1. PRODUCCIÓN
    # ⚠️ CAMBIO AQUÍ: Probamos con 'ventas' (plural) en vez de 'venta'
    try:
        query_prod = text("""
            SELECT COALESCE(SUM(vi.subtotal_item_neto), 0)
            FROM venta_items vi
            JOIN ventas v ON vi.venta_id = v.id  -- CAMBIADO 'venta' POR 'ventas'
            WHERE v.empleado_id = :uid
            AND vi.servicio_id IS NOT NULL
            AND vi.es_trabajo_extra = false
            AND v.fecha BETWEEN :start AND :end
        """)
        production = db.execute(query_prod, {"uid": user_id, "start": start, "end": end}).scalar()
    except Exception as e:
        print(f"❌ ERROR SQL PRODUCCIÓN: {e}")
        db.rollback()
        production = 0

    # 2. COMISIONES
    try:
        query_com_pending = text("""
            SELECT COALESCE(SUM(monto_comision), 0) FROM comisiones 
            WHERE empleado_id = :uid AND estado = 'Pendiente'
        """)
        pending_comm = db.execute(query_com_pending, {"uid": user_id}).scalar()
    except Exception as e:
        print(f"❌ ERROR SQL COMISIONES: {e}")
        db.rollback()
        pending_comm = 0

    # 3. METRICAS DUMMY
    rating = 4.8
    completed_services = 12

    # 4. PRÓXIMA CITA
    # ⚠️ CAMBIO AQUÍ: Probamos con 'reservas' (plural) en vez de 'reserva'
    next_appt = None
    try:
        query_next = text("""
            SELECT fecha_hora_inicio, servicio_id, cliente_id 
            FROM reservas                      -- CAMBIADO 'reserva' POR 'reservas'
            WHERE empleado_id = :uid 
            AND estado = 'Programada' 
            AND fecha_hora_inicio >= NOW()
            ORDER BY fecha_hora_inicio ASC 
            LIMIT 1
        """)
        next_appt_row = db.execute(query_next, {"uid": user_id}).first()
        
        if next_appt_row:
            next_appt = {
                "time": next_appt_row.fecha_hora_inicio.strftime("%H:%M"),
                "client": f"Cliente #{next_appt_row.cliente_id}", 
                "service": "Servicio Agendado"
            }
    except Exception as e:
        print(f"❌ ERROR SQL CITA: {e}")
        db.rollback()

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


# --- AGREGAR AL FINAL DE staff.py ---
from sqlalchemy import inspect

@router.get("/debug/structure")
def get_db_structure(db: Session = Depends(get_db)):
    """
    Esta función inspecciona la base de datos y devuelve 
    todos los nombres de tablas y sus columnas.
    """
    inspector = inspect(db.get_bind())
    schema_info = {}
    
    # 1. Obtener todas las tablas
    table_names = inspector.get_table_names()
    
    for table in table_names:
        columns = []
        # 2. Obtener columnas de cada tabla
        for col in inspector.get_columns(table):
            columns.append(f"{col['name']} ({col['type']})")
        schema_info[table] = columns
        
    return schema_info