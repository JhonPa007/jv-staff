from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime
import locale

from app.database import get_db
from app.routers.auth import get_current_user

router = APIRouter(prefix="/staff", tags=["Staff"])

@router.get("/dashboard")
def get_dashboard(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    # 1. Identificar al empleado (Usamos 'empleado_id' en las consultas)
    user_id = current_user.id
    
    # Nombre para el saludo
    try:
        user_name = current_user.first_name if hasattr(current_user, 'first_name') else current_user.email.split('@')[0]
    except:
        user_name = "Barbero"

    # Periodo (Fecha actual)
    try:
        locale.setlocale(locale.LC_TIME, 'es_ES.UTF-8')
    except:
        pass
    periodo = datetime.now().strftime("%B %Y").capitalize()

    # -------------------------------------------------------------------------
    # A) PRODUCCIÓN: Tabla 'venta_items'
    # -------------------------------------------------------------------------
    # Regla: Suma 'subtotal_item_neto' SI servicio_id != null AND es_trabajo_extra = false
    # Asumimos que 'venta_items' tiene una columna 'empleado_id'.
    query_prod = text("""
        SELECT COALESCE(SUM(subtotal_item_neto), 0)
        FROM venta_items
        WHERE empleado_id = :uid
        AND servicio_id IS NOT NULL
        AND es_trabajo_extra = false
    """)
    total_production = db.execute(query_prod, {"uid": user_id}).scalar() or 0.0

    # -------------------------------------------------------------------------
    # B) COMISIONES PENDIENTES: Tabla 'comisiones'
    # -------------------------------------------------------------------------
    # Regla: Suma 'monto_comision' donde estado = 'Pendiente'
    query_com = text("""
        SELECT COALESCE(SUM(monto_comision), 0)
        FROM comisiones
        WHERE empleado_id = :uid
        AND estado = 'Pendiente'
    """)
    total_commission = db.execute(query_com, {"uid": user_id}).scalar() or 0.0

    # -------------------------------------------------------------------------
    # C) PRÓXIMA CITA: Tabla 'reservas' (singular/plural según tu imagen)
    # -------------------------------------------------------------------------
    # Regla: estado = 'Programada', >= hoy. Traer IDs y fecha.
    query_cita = text("""
        SELECT fecha_hora_inicio, cliente_id, servicio_id
        FROM reservas
        WHERE empleado_id = :uid
        AND estado = 'Programada'
        AND fecha_hora_inicio >= NOW()
        ORDER BY fecha_hora_inicio ASC
        LIMIT 1
    """)
    
    row_cita = db.execute(query_cita, {"uid": user_id}).first()

    # Procesamos la cita para que no rompa si no hay ninguna
    next_appointment = None
    if row_cita:
        # NOTA: Como solo tenemos IDs, mostramos el número.
        # En el futuro haremos un JOIN con la tabla 'clientes' y 'servicios'
        client_display = f"Cliente #{row_cita.cliente_id}"
        service_display = f"Servicio #{row_cita.servicio_id}"
        
        # Formateamos la hora (ej: 14:30)
        time_str = row_cita.fecha_hora_inicio.strftime("%H:%M")
        
        next_appointment = {
            "time": time_str,
            "client": client_display,
            "service": service_display
        }

    # Calculamos "Servicios Completados" (Opcional: conteo simple)
    # Usamos la misma lógica de producción para contar cuántos items vendió
    query_count = text("""
        SELECT COUNT(*)
        FROM venta_items
        WHERE empleado_id = :uid
        AND servicio_id IS NOT NULL
        AND es_trabajo_extra = false
    """)
    completed_services = db.execute(query_count, {"uid": user_id}).scalar() or 0

    # -------------------------------------------------------------------------
    # 4. RESPUESTA FINAL
    # -------------------------------------------------------------------------
    return {
        "period": periodo,
        "metrics": {
            "total_production": float(total_production),
            "total_commission_pending": float(total_commission),
            "rating": 5.0, # Dato fijo por ahora
            "completed_services": int(completed_services)
        },
        "next_appointment": next_appointment, # Puede ser null o el objeto cita
        "user_name": user_name
    }