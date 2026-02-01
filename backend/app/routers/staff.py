from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date, datetime
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
    # Nombre del usuario (de email o tabla empleados si quisieras hacer otro query)
    user_name = current_user.email.split('@')[0].capitalize()
    
    start, end = get_date_range(start_date, end_date)

    # 1. PRODUCCIÓN (Corregido con nombres reales)
    # Tabla: ventas (plural), Columna Fecha: fecha_venta
    try:
        query_prod = text("""
            SELECT COALESCE(SUM(vi.subtotal_item_neto), 0)
            FROM venta_items vi
            JOIN ventas v ON vi.venta_id = v.id
            WHERE v.empleado_id = :uid
            AND vi.servicio_id IS NOT NULL
            AND vi.es_trabajo_extra = false
            AND v.fecha_venta BETWEEN :start AND :end
        """)
        # Nota: Postgres a veces pide casting explícito para fechas si la columna es TIMESTAMP
        # 'start' y 'end' son DATE, 'fecha_venta' es TIMESTAMP. Postgres suele manejarlo,
        # pero si falla, usaremos ::date en la query.
        
        production = db.execute(query_prod, {"uid": user_id, "start": start, "end": end}).scalar()
    except Exception as e:
        print(f"❌ ERROR SQL PRODUCCIÓN: {e}")
        db.rollback()
        production = 0

    # 2. COMISIONES
    # Tabla: comisiones
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

    # 3. MÉTRICAS DUMMY (Rating y Servicios Completados)
    # Puedes implementar queries reales aquí si tienes las tablas 'calificaciones' o contar 'reservas' finalizadas.
    # Por ahora dejamos un conteo real de servicios completados en el periodo:
    try:
        query_completed = text("""
            SELECT COUNT(*) FROM reservas
            WHERE empleado_id = :uid
            AND estado = 'Finalizado' -- O el estado que uses para completado
            AND fecha_hora_inicio BETWEEN :start AND :end
        """)
        completed_services = db.execute(query_completed, {"uid": user_id, "start": start, "end": end}).scalar() or 0
    except:
        db.rollback()
        completed_services = 0
        
    rating = 4.8 # Valor fijo por ahora

    # 4. PRÓXIMA CITA
    # Tabla: reservas
    next_appt = None
    try:
        query_next = text("""
            SELECT r.fecha_hora_inicio, s.nombre as servicio_nombre, c.razon_social_nombres as cliente_nombre, c.apellidos as cliente_apellido
            FROM reservas r
            LEFT JOIN servicios s ON r.servicio_id = s.id
            LEFT JOIN clientes c ON r.cliente_id = c.id
            WHERE r.empleado_id = :uid 
            AND r.estado = 'Programada' 
            AND r.fecha_hora_inicio >= NOW()
            ORDER BY r.fecha_hora_inicio ASC 
            LIMIT 1
        """)
        next_appt_row = db.execute(query_next, {"uid": user_id}).first()
        
        if next_appt_row:
            # Construimos el nombre del cliente
            client_full = next_appt_row.cliente_nombre or "Cliente"
            if next_appt_row.cliente_apellido:
                client_full += f" {next_appt_row.cliente_apellido}"

            next_appt = {
                "time": next_appt_row.fecha_hora_inicio.strftime("%H:%M"),
                "client": client_full, 
                "service": next_appt_row.servicio_nombre or "Servicio"
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
            "completed_services": int(completed_services)
        },
        "next_appointment": next_appt
    }

# --- ENDPOINT DE DEBUG (YA NO LO NECESITAS, PUEDES BORRARLO O DEJARLO) ---
# ...