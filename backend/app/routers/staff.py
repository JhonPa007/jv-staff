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

# -----------------------------------------------------------------------------
# NUEVOS ENDPOINTS FINANCIEROS
# -----------------------------------------------------------------------------
from typing import Optional
from fastapi import Query

@router.get("/finance/summary")
def get_finance_summary(
    start_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    end_date: Optional[str] = Query(None, description="YYYY-MM-DD"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    user_id = current_user.id
    
    # Fechas por defecto: Mes actual
    if not start_date:
        start_date = datetime.now().strftime("%Y-%m-01")
    if not end_date:
        # Fin de mes (simple logic: hoy, o un día lejano del año 3000 si quieres 'hasta ahora')
        # Para ser prácticos, usaremos 'hasta hoy' o el usuario mandará fin de mes
        end_date = datetime.now().strftime("%Y-%m-%d")

    # A) PRODUCCIÓN
    # Join con 'ventas' para filtrar por fecha
    query_prod = text("""
        SELECT COALESCE(SUM(vi.subtotal_item_neto), 0)
        FROM venta_items vi
        JOIN ventas v ON vi.venta_id = v.id
        WHERE vi.empleado_id = :uid
        AND vi.servicio_id IS NOT NULL
        AND vi.es_trabajo_extra = false
        AND v.fecha_emision BETWEEN :start AND :end
    """)
    production = db.execute(query_prod, {"uid": user_id, "start": start_date, "end": end_date}).scalar() or 0.0

    # B) COMISIONES
    # Pendientes (Histórico total)
    query_com_pending = text("""
        SELECT COALESCE(SUM(monto_comision), 0)
        FROM comisiones
        WHERE empleado_id = :uid
        AND estado = 'Pendiente'
    """)
    com_pending = db.execute(query_com_pending, {"uid": user_id}).scalar() or 0.0

    # Pagadas (En el rango) -> Asumimos fecha_pago en comisiones
    query_com_paid = text("""
        SELECT COALESCE(SUM(monto_comision), 0)
        FROM comisiones
        WHERE empleado_id = :uid
        AND estado = 'Pagado'
        AND fecha_pago BETWEEN :start AND :end
    """)
    com_paid = db.execute(query_com_paid, {"uid": user_id, "start": start_date, "end": end_date}).scalar() or 0.0

    # C) PROPINAS
    # Asumimos tabla 'propinas' con 'fecha' y 'empleado_id'
    # OJO: Si no existe la tabla, esto fallará. Ajustar según esquema real.
    try:
        query_tips = text("""
            SELECT COALESCE(SUM(monto), 0)
            FROM propinas
            WHERE empleado_id = :uid
            AND fecha BETWEEN :start AND :end
            AND estado = 'Cobradas' -- Opcional, según lógica de negocio
        """)
        tips_collected = db.execute(query_tips, {"uid": user_id, "start": start_date, "end": end_date}).scalar() or 0.0
        
        # Propinas pendientes? (Opcional)
        query_tips_pending = text("""
            SELECT COALESCE(SUM(monto), 0)
            FROM propinas
            WHERE empleado_id = :uid
            AND fecha BETWEEN :start AND :end
            AND estado != 'Cobradas' 
        """)
        tips_pending = db.execute(query_tips_pending, {"uid": user_id, "start": start_date, "end": end_date}).scalar() or 0.0
    except:
        # Si explota (no tabla), devolvemos 0
        tips_collected = 0.0
        tips_pending = 0.0

    return {
        "production": float(production),
        "commissions": {
            "pending": float(com_pending),
            "paid": float(com_paid)
        },
        "tips": {
            "collected": float(tips_collected),
            "pending": float(tips_pending)
        },
        "period": {
            "start": start_date,
            "end": end_date
        }
    }

@router.get("/sales/history")
def get_sales_history(
    start_date: Optional[str] = Query(None),
    end_date: Optional[str] = Query(None),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    user_id = current_user.id
    if not start_date: start_date = datetime.now().strftime("%Y-%m-01")
    if not end_date: end_date = datetime.now().strftime("%Y-%m-%d")

    # Ventas Detalladas
    # Join v.items -> ventas -> clientes -> servicios(item)
    # NOTA: Ajustar nombres de tablas/columnas según esquema real
    query_history = text("""
        SELECT 
            v.fecha_emision,
            c.nombres || ' ' || c.apellidos as cliente,
            v.serie_comprobante || '-' || v.numero_comprobante as comprobante,
            s.nombre as item_nombre,
            vi.subtotal_item_neto as precio
        FROM venta_items vi
        JOIN ventas v ON vi.venta_id = v.id
        LEFT JOIN clientes c ON v.cliente_id = c.id
        LEFT JOIN servicios s ON vi.servicio_id = s.id
        WHERE vi.empleado_id = :uid
        AND v.fecha_emision BETWEEN :start AND :end
        ORDER BY v.fecha_emision DESC
    """)

    results = db.execute(query_history, {"uid": user_id, "start": start_date, "end": end_date}).fetchall()
    
    history = []
    for row in results:
        history.append({
            "date": row.fecha_emision, # Puede que necesite str()
            "client": row.cliente or "Anónimo",
            "collaborator": current_user.first_name, # Es el logueado
            "receipt": row.comprobante,
            "item": row.item_nombre or "Item",
            "price": float(row.precio)
        })

    return history