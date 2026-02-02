from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import date, datetime, timedelta
from typing import Optional
import shutil
import os
import uuid

from app.database import get_db
from app.routers.auth import get_current_user 

router = APIRouter(prefix="/staff", tags=["Staff Reports"])

# --- AJUSTE DE HORA Y FECHA ---
def get_peru_now():
    """Hora actual en Perú"""
    return datetime.utcnow() - timedelta(hours=5)

def get_date_range(start_date: Optional[date], end_date: Optional[date]):
    today_peru = get_peru_now().date()
    
    if not start_date:
        # CAMBIO CLAVE: Por defecto miramos desde el 1 de ENERO del año actual
        # Así no perdemos datos si estamos a inicios de mes.
        start_date = date(today_peru.year, 1, 1) 
    
    if not end_date:
        # Hasta fin de mes actual (para cubrir todo)
        if today_peru.month == 12:
            end_date = date(today_peru.year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(today_peru.year, today_peru.month + 1, 1) - timedelta(days=1)
            
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
    start, end = get_date_range(start_date, end_date)
    
    print(f"DEBUG: Buscando datos para Usuario ID {user_id} entre {start} y {end}")

    # A. OBTENER NOMBRE REAL DEL COLABORADOR
    # Buscamos en la tabla empleados en lugar de usar el email
    try:
        query_name = text("SELECT nombres, apellidos FROM empleados WHERE id = :uid")
        emp = db.execute(query_name, {"uid": user_id}).first()
        if emp:
            user_name = f"{emp.nombres}".split()[0] # Primer nombre
        else:
            user_name = current_user.email.split('@')[0].capitalize()
    except Exception as e:
        print(f"Error Nombre: {e}")
        user_name = "Colaborador"

    # B. PRODUCCIÓN
    # Nota: Asegúrate que tus ventas tengan fecha_venta dentro del rango
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
    except Exception as e:
        print(f"Error Produccion: {e}")
        production = 0

    # C. COMISIONES PENDIENTES (Sin filtro de fecha, queremos ver todo lo que nos deben)
    try:
        query_com = text("""
            SELECT COALESCE(SUM(monto_comision), 0) 
            FROM comisiones 
            WHERE empleado_id = :uid AND estado = 'Pendiente'
        """)
        pending = db.execute(query_com, {"uid": user_id}).scalar() or 0
    except:
        pending = 0

    # D. PRÓXIMA CITA
    # Quitamos el filtro estricto de 'Programada' por si usas otro estado
    next_appt = None
    try:
        query_next = text("""
            SELECT r.fecha_hora_inicio, s.nombre, c.razon_social_nombres, c.apellidos
            FROM reservas r
            LEFT JOIN servicios s ON r.servicio_id = s.id
            LEFT JOIN clientes c ON r.cliente_id = c.id
            WHERE r.empleado_id = :uid 
            AND r.fecha_hora_inicio >= :now  -- Solo futuras
            AND r.estado NOT IN ('Cancelado', 'Anulado') -- Mostrar cualquiera activa
            ORDER BY r.fecha_hora_inicio ASC 
            LIMIT 1
        """)
        
        # Retrocedemos 24 horas en el 'now' por si hubo confusión de zona horaria
        check_time = get_peru_now() - timedelta(hours=24)
        
        row = db.execute(query_next, {"uid": user_id, "now": check_time}).first()
        
        if row:
            client = f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip() or "Cliente"
            next_appt = {
                "time": row.fecha_hora_inicio.strftime("%d/%m %H:%M"), # Agregué día/mes para claridad
                "client": client, 
                "service": row.nombre or "Servicio"
            }
    except Exception as e:
        print(f"Error Cita: {e}")

    # Texto del periodo
    periodo_texto = f"Desde Enero {start.year}"

    return {
        "period": periodo_texto,
        "user_name": user_name,
        "metrics": {
            "total_production": float(production), 
            "total_commission_pending": float(pending), 
            "total_commission_paid": 0.0, 
            "rating": 5.0, 
            "completed_services": 0
        },
        "next_appointment": next_appt
    }

# --- 2. LISTADO DE CITAS ---
@router.get("/appointments")
def get_appointments(
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    # Traemos TODO lo futuro para depurar
    query_str = """
        SELECT r.id, r.fecha_hora_inicio, r.estado, r.evidencia_url,
               s.nombre as servicio, 
               c.razon_social_nombres, c.apellidos, c.telefono
        FROM reservas r
        LEFT JOIN servicios s ON r.servicio_id = s.id
        LEFT JOIN clientes c ON r.cliente_id = c.id
        WHERE r.empleado_id = :uid
        AND r.fecha_hora_inicio >= :today
        ORDER BY r.fecha_hora_inicio ASC
    """
    
    today = get_peru_now().date()
    
    try:
        rows = db.execute(text(query_str), {"uid": current_user.id, "today": today}).fetchall()
        return [{
            "id": row.id,
            "date": row.fecha_hora_inicio.strftime("%Y-%m-%d"),
            "time": row.fecha_hora_inicio.strftime("%H:%M"),
            "client_name": f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip(),
            "service": row.servicio or "Servicio",
            "status": row.estado,
            "evidence_url": row.evidencia_url
        } for row in rows]
    except:
        return []

# --- 3. COMPLETAR CITA (SUBIDA DE FOTO) ---
@router.post("/appointments/{appt_id}/complete")
async def complete_appointment(
    appt_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    upload_dir = "uploads/evidence"
    os.makedirs(upload_dir, exist_ok=True)
    
    extension = file.filename.split(".")[-1]
    filename = f"evidencia_{appt_id}_{uuid.uuid4().hex[:8]}.{extension}"
    file_path = f"{upload_dir}/{filename}"
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    public_url = f"/static/evidence/{filename}"

    try:
        # Actualizamos estado a 'Finalizado' (o el nombre que uses en tu BD)
        update_query = text("""
            UPDATE reservas 
            SET estado = 'Finalizado', evidencia_url = :url 
            WHERE id = :aid AND empleado_id = :uid
        """)
        db.execute(update_query, {"url": public_url, "aid": appt_id, "uid": current_user.id})
        db.commit()
        return {"message": "Cita completada", "url": public_url}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))