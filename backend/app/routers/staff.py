from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date, datetime, timedelta
from typing import Optional, List
import shutil
import os
import uuid

from app.database import get_db
from app.routers.auth import get_current_user 

router = APIRouter(prefix="/staff", tags=["Staff Reports"])

# --- UTILIDADES ---
def get_peru_date():
    """Retorna la fecha actual en Perú (UTC-5)"""
    return (datetime.utcnow() - timedelta(hours=5)).date()

def get_date_range(start_date: Optional[date], end_date: Optional[date]):
    today_peru = get_peru_date()
    if not start_date:
        start_date = date(today_peru.year, today_peru.month, 1)
    if not end_date:
        end_date = today_peru
    return start_date, end_date

# --- 1. DASHBOARD PRINCIPAL ---
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

    # Producción
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
        production = db.execute(query_prod, {"uid": user_id, "start": start, "end": end}).scalar() or 0
    except:
        production = 0

    # Comisiones Pendientes
    try:
        query_com = text("SELECT COALESCE(SUM(monto_comision), 0) FROM comisiones WHERE empleado_id = :uid AND estado = 'Pendiente'")
        pending = db.execute(query_com, {"uid": user_id}).scalar() or 0
    except:
        pending = 0

    # Traducción de Mes
    meses = {1:"Enero", 2:"Febrero", 3:"Marzo", 4:"Abril", 5:"Mayo", 6:"Junio", 7:"Julio", 8:"Agosto", 9:"Septiembre", 10:"Octubre", 11:"Noviembre", 12:"Diciembre"}
    periodo = f"{meses.get(start.month, 'Mes')} {start.year}"

    # Próxima Cita
    next_appt = None
    try:
        query_next = text("""
            SELECT r.fecha_hora_inicio, s.nombre, c.razon_social_nombres, c.apellidos
            FROM reservas r
            LEFT JOIN servicios s ON r.servicio_id = s.id
            LEFT JOIN clientes c ON r.cliente_id = c.id
            WHERE r.empleado_id = :uid AND r.estado = 'Programada' AND r.fecha_hora_inicio >= NOW() - INTERVAL '5 hours'
            ORDER BY r.fecha_hora_inicio ASC LIMIT 1
        """)
        row = db.execute(query_next, {"uid": user_id}).first()
        if row:
            client = f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip() or "Cliente"
            next_appt = {"time": row.fecha_hora_inicio.strftime("%H:%M"), "client": client, "service": row.nombre or "Servicio"}
    except:
        pass

    return {
        "period": periodo,
        "user_name": user_name,
        "metrics": {"total_production": float(production), "total_commission_pending": float(pending), "total_commission_paid": 0.0, "rating": 4.8, "completed_services": 0},
        "next_appointment": next_appt
    }

# --- 2. LISTADO DE CITAS (PENDIENTES O HISTORIAL) ---
@router.get("/appointments")
def get_appointments(
    status: Optional[str] = 'Programada', # 'Programada', 'Finalizado', 'Cancelado'
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    user_id = current_user.id
    # Si no envían fechas, mostramos las de hoy en adelante para programadas
    # O las del mes actual para historial
    start, end = get_date_range(start_date, end_date)
    
    query_str = """
        SELECT r.id, r.fecha_hora_inicio, r.estado, r.evidencia_url,
               s.nombre as servicio, 
               c.razon_social_nombres, c.apellidos, c.telefono
        FROM reservas r
        LEFT JOIN servicios s ON r.servicio_id = s.id
        LEFT JOIN clientes c ON r.cliente_id = c.id
        WHERE r.empleado_id = :uid
    """
    
    params = {"uid": user_id}

    if status:
        query_str += " AND r.estado = :status"
        params["status"] = status
    
    # Filtro de fecha
    if status == 'Programada':
        # Para programadas, queremos ver futuras (o de hoy)
        query_str += " AND r.fecha_hora_inicio >= :today"
        params["today"] = datetime.now() - timedelta(hours=5) # Desde hoy
    else:
        # Para finalizadas, usamos el rango
        query_str += " AND r.fecha_hora_inicio BETWEEN :start AND :end"
        params["start"] = start
        params["end"] = end

    query_str += " ORDER BY r.fecha_hora_inicio ASC"

    try:
        rows = db.execute(text(query_str), params).fetchall()
        appointments = []
        for row in rows:
            client_name = f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip()
            appointments.append({
                "id": row.id,
                "date": row.fecha_hora_inicio.strftime("%Y-%m-%d"),
                "time": row.fecha_hora_inicio.strftime("%H:%M"),
                "client_name": client_name or "Cliente General",
                "phone": row.telefono,
                "service": row.servicio or "Servicio",
                "status": row.estado,
                "evidence_url": row.evidencia_url
            })
        return appointments
    except Exception as e:
        print(f"Error Appointments: {e}")
        return []

# --- 3. COMPLETAR CITA Y SUBIR EVIDENCIA ---
@router.post("/appointments/{appt_id}/complete")
async def complete_appointment(
    appt_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    # 1. Guardar archivo
    upload_dir = "uploads/evidence"
    os.makedirs(upload_dir, exist_ok=True)
    
    # Generar nombre único
    extension = file.filename.split(".")[-1]
    filename = f"evidencia_{appt_id}_{uuid.uuid4().hex[:8]}.{extension}"
    file_path = f"{upload_dir}/{filename}"
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    # URL pública (asumiendo que servimos estáticos en /static)
    # Nota: En main.py debes tener: app.mount("/static", StaticFiles(directory="uploads"), name="static")
    public_url = f"/static/evidence/{filename}"

    # 2. Actualizar BD
    try:
        update_query = text("""
            UPDATE reservas 
            SET estado = 'Finalizado', evidencia_url = :url, fecha_actualizacion = NOW()
            WHERE id = :aid AND empleado_id = :uid
        """)
        db.execute(update_query, {"url": public_url, "aid": appt_id, "uid": current_user.id})
        db.commit()
        return {"message": "Cita completada con éxito", "url": public_url}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# --- 4. REPORTES (VENTAS, COMISIONES, PROPINAS) ---
@router.get("/reports/sales")
def get_sales_report(
    start_date: Optional[date] = None, 
    end_date: Optional[date] = None,
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user)
):
    start, end = get_date_range(start_date, end_date)
    uid = current_user.id
    
    query = text("""
        SELECT v.fecha_venta, 
               c.razon_social_nombres, c.apellidos, 
               v.serie_comprobante, v.numero_comprobante,
               s.nombre as servicio, p.nombre as producto,
               vi.subtotal_item_neto as precio
        FROM venta_items vi
        JOIN ventas v ON vi.venta_id = v.id
        LEFT JOIN clientes c ON v.cliente_facturacion_id = c.id
        LEFT JOIN servicios s ON vi.servicio_id = s.id
        LEFT JOIN productos p ON vi.producto_id = p.id
        WHERE v.empleado_id = :uid AND v.fecha_venta BETWEEN :start AND :end
        ORDER BY v.fecha_venta DESC
    """)
    
    try:
        rows = db.execute(query, {"uid": uid, "start": start, "end": end}).fetchall()
        return [{
            "date": row.fecha_venta.strftime("%d/%m/%Y"),
            "client": f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip(),
            "receipt": f"{row.serie_comprobante}-{row.numero_comprobante}",
            "item": row.servicio or row.producto or "Item",
            "price": float(row.precio or 0)
        } for row in rows]
    except Exception as e:
        print(f"Error Sales: {e}")
        return []

@router.get("/reports/commissions")
def get_commissions_report(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    status: Optional[str] = None, # 'Pendiente' o 'Pagado'
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    start, end = get_date_range(start_date, end_date)
    uid = current_user.id
    
    sql = """
        SELECT c.fecha_generacion, c.monto_comision, c.estado,
               s.nombre as servicio
        FROM comisiones c
        LEFT JOIN venta_items vi ON c.venta_item_id = vi.id
        LEFT JOIN servicios s ON vi.servicio_id = s.id
        WHERE c.empleado_id = :uid AND c.fecha_generacion BETWEEN :start AND :end
    """
    if status:
        sql += " AND c.estado = :status"
    
    sql += " ORDER BY c.fecha_generacion DESC"
    
    try:
        rows = db.execute(text(sql), {"uid": uid, "start": start, "end": end, "status": status}).fetchall()
        return [{
            "date": row.fecha_generacion.strftime("%d/%m/%Y"),
            "amount": float(row.monto_comision or 0),
            "status": row.estado,
            "concept": row.servicio or "Comisión Venta"
        } for row in rows]
    except:
        return []

@router.get("/reports/tips")
def get_tips_report(
    start_date: Optional[date] = None, 
    end_date: Optional[date] = None,
    db: Session = Depends(get_db), 
    current_user: dict = Depends(get_current_user)
):
    start, end = get_date_range(start_date, end_date)
    query = text("""
        SELECT fecha_registro, monto, metodo_pago, entregado_al_barbero
        FROM propinas
        WHERE empleado_id = :uid AND fecha_registro BETWEEN :start AND :end
        ORDER BY fecha_registro DESC
    """)
    try:
        rows = db.execute(query, {"uid": current_user.id, "start": start, "end": end}).fetchall()
        return [{
            "date": row.fecha_registro.strftime("%d/%m/%Y"),
            "amount": float(row.monto or 0),
            "method": row.metodo_pago,
            "status": "Pagado" if row.entregado_al_barbero else "Pendiente"
        } for row in rows]
    except:
        return []