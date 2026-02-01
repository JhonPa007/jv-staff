from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date, datetime, timedelta
from typing import Optional

from app.database import get_db
from app.routers.auth import get_current_user 

router = APIRouter(prefix="/staff", tags=["Staff Reports"])

# --- AJUSTE DE HORA Y FECHA (PERÚ) ---
def get_date_range(start_date: Optional[date], end_date: Optional[date]):
    # 1. Obtenemos la hora actual y le restamos 5 horas (UTC-5 Perú)
    utc_now = datetime.utcnow()
    peru_time = utc_now - timedelta(hours=5)
    today_peru = peru_time.date()

    if not start_date:
        start_date = date(today_peru.year, today_peru.month, 1)
    
    if not end_date:
        end_date = today_peru
        
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

    # 3. MÉTRICAS DUMMY
    try:
        query_completed = text("""
            SELECT COUNT(*) FROM reservas
            WHERE empleado_id = :uid
            AND estado = 'Finalizado' 
            AND fecha_hora_inicio BETWEEN :start AND :end
        """)
        completed_services = db.execute(query_completed, {"uid": user_id, "start": start, "end": end}).scalar() or 0
    except:
        db.rollback()
        completed_services = 0
        
    rating = 4.8

    # 4. PRÓXIMA CITA
    next_appt = None
    try:
        query_next = text("""
            SELECT r.fecha_hora_inicio, s.nombre as servicio_nombre, c.razon_social_nombres as cliente_nombre, c.apellidos as cliente_apellido
            FROM reservas r
            LEFT JOIN servicios s ON r.servicio_id = s.id
            LEFT JOIN clientes c ON r.cliente_id = c.id
            WHERE r.empleado_id = :uid 
            AND r.estado = 'Programada' 
            AND r.fecha_hora_inicio >= NOW() - INTERVAL '5 hours' -- Ajuste de seguridad
            ORDER BY r.fecha_hora_inicio ASC 
            LIMIT 1
        """)
        
        next_appt_row = db.execute(query_next, {"uid": user_id}).first()
        
        if next_appt_row:
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

    # --- TRADUCCIÓN MANUAL DE MESES ---
    meses_es = {
        1: "Enero", 2: "Febrero", 3: "Marzo", 4: "Abril",
        5: "Mayo", 6: "Junio", 7: "Julio", 8: "Agosto",
        9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre"
    }
    nombre_mes = meses_es.get(start.month, "Mes")
    periodo_espanol = f"{nombre_mes} {start.year}"
    # ----------------------------------

    return {
        "period": periodo_espanol, # <--- Usamos la variable en español
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