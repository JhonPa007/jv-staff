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

# --- UTILIDADES DE TIEMPO (PERÚ UTC-5) ---
def get_peru_now():
    return datetime.utcnow() - timedelta(hours=5)

def get_date_range(start_date: Optional[date], end_date: Optional[date]):
    today = get_peru_now().date()
    # Por defecto: Mes actual estricto (ej: Febrero 1 a Febrero 28)
    if not start_date:
        start_date = date(today.year, today.month, 1)
    if not end_date:
        if today.month == 12:
            end_date = date(today.year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(today.year, today.month + 1, 1) - timedelta(days=1)
    return start_date, end_date

# --- HELPER: OBTENER EMPLEADO REAL ---
def get_logged_employee(db: Session, current_user: dict):
    """
    Busca al empleado en la BD usando el email del token.
    Retorna el objeto empleado con su ID real (ej: 10 para Renato).
    """
    email = current_user.email
    query = text("SELECT * FROM empleados WHERE email = :email LIMIT 1")
    employee = db.execute(query, {"email": email}).mappings().first()
    
    if not employee:
        raise HTTPException(status_code=404, detail="Colaborador no encontrado en base de datos.")
    
    if not employee['activo']:
        raise HTTPException(status_code=403, detail="Tu cuenta de colaborador está inactiva. Contacta al administrador.")
        
    return employee

# ==========================================
# 1. DASHBOARD PRINCIPAL
# ==========================================
@router.get("/dashboard")
def get_dashboard(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    # 1. Identificar al Empleado Real (Renato -> ID 10)
    emp = get_logged_employee(db, current_user)
    uid = emp['id']
    
    # Nombre para mostrar (Nombres + Apellido Paterno)
    full_name = f"{emp['nombres'].split()[0]} {emp['apellidos'].split()[0]}".title()

    # Fechas
    start, end = get_date_range(start_date, end_date)

    # 2. PRODUCCIÓN (Ventas netas)
    try:
        query_prod = text("""
            SELECT COALESCE(SUM(vi.subtotal_item_neto), 0)
            FROM venta_items vi
            JOIN ventas v ON vi.venta_id = v.id
            WHERE v.empleado_id = :uid
            AND vi.servicio_id IS NOT NULL -- Solo servicios cuentan para producción base
            AND v.fecha_venta BETWEEN :start AND :end
        """)
        production = db.execute(query_prod, {"uid": uid, "start": start, "end": end}).scalar() or 0
    except Exception as e:
        print(f"Error Prod: {e}")
        production = 0

    # 3. COMISIONES PENDIENTES (Total acumulado histórico)
    try:
        query_com = text("""
            SELECT COALESCE(SUM(monto_comision), 0) FROM comisiones 
            WHERE empleado_id = :uid AND estado = 'Pendiente'
        """)
        pending_comm = db.execute(query_com, {"uid": uid}).scalar() or 0
    except:
        pending_comm = 0

    # 4. PRÓXIMA CITA (O la más urgente pendiente)
    # Buscamos la más antigua que siga en estado 'Programada'
    next_appt = None
    try:
        query_next = text("""
            SELECT r.fecha_hora_inicio, s.nombre, c.razon_social_nombres, c.apellidos
            FROM reservas r
            LEFT JOIN servicios s ON r.servicio_id = s.id
            LEFT JOIN clientes c ON r.cliente_id = c.id
            WHERE r.empleado_id = :uid 
            AND r.estado = 'Programada'
            ORDER BY r.fecha_hora_inicio ASC 
            LIMIT 1
        """)
        row = db.execute(query_next, {"uid": uid}).first()
        
        if row:
            client_name = f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip() or "Cliente"
            # Formato amigable: "02 Feb - 10:00"
            formatted_time = row.fecha_hora_inicio.strftime("%d/%m %H:%M")
            next_appt = {
                "time": formatted_time,
                "client": client_name,
                "service": row.nombre or "Servicio General"
            }
    except Exception as e:
        print(f"Error Cita: {e}")

    # Texto del Periodo
    meses = {1:"Enero", 2:"Febrero", 3:"Marzo", 4:"Abril", 5:"Mayo", 6:"Junio", 7:"Julio", 8:"Agosto", 9:"Septiembre", 10:"Octubre", 11:"Noviembre", 12:"Diciembre"}
    periodo_txt = f"{meses.get(start.month)} {start.year}"

    return {
        "period": periodo_txt,
        "user_name": full_name,
        "metrics": {
            "total_production": float(production),
            "total_commission_pending": float(pending_comm),
            "total_commission_paid": 0.0,
            "rating": 5.0, 
            "completed_services": 0
        },
        "next_appointment": next_appt
    }

# ==========================================
# 2. LISTADO DE CITAS
# ==========================================
@router.get("/appointments")
def get_appointments(
    status: Optional[str] = None, # 'Programada', 'Finalizado'
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    emp = get_logged_employee(db, current_user)
    
    query = """
        SELECT r.id, r.fecha_hora_inicio, r.estado, r.evidencia_url,
               s.nombre as servicio, 
               c.razon_social_nombres, c.apellidos, c.telefono
        FROM reservas r
        LEFT JOIN servicios s ON r.servicio_id = s.id
        LEFT JOIN clientes c ON r.cliente_id = c.id
        WHERE r.empleado_id = :uid
    """
    
    # Si piden pendientes, traemos TODO lo Programado (incluso pasado)
    if status == 'Programada':
        query += " AND r.estado = 'Programada'"
    elif status:
        query += " AND r.estado = :status"
        
    query += " ORDER BY r.fecha_hora_inicio ASC"
    
    try:
        rows = db.execute(text(query), {"uid": emp['id'], "status": status}).fetchall()
        return [{
            "id": row.id,
            "date": row.fecha_hora_inicio.strftime("%Y-%m-%d"),
            "time": row.fecha_hora_inicio.strftime("%H:%M"),
            "client_name": f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip(),
            "phone": row.telefono,
            "service": row.servicio or "Servicio",
            "status": row.estado,
            "evidence_url": row.evidencia_url
        } for row in rows]
    except:
        return []

# ==========================================
# 3. REPORTES: VENTAS (Fecha | Cliente | Item | Precio)
# ==========================================
@router.get("/reports/sales")
def get_sales_report(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    emp = get_logged_employee(db, current_user)
    start, end = get_date_range(start_date, end_date)
    
    # Consulta híbrida: Trae Servicios Y Productos vendidos
    query = text("""
        SELECT v.fecha_venta, 
               c.razon_social_nombres, c.apellidos,
               v.serie_comprobante, v.numero_comprobante,
               COALESCE(s.nombre, p.nombre, 'Item Varios') as item_nombre,
               vi.subtotal_item_neto as precio,
               CASE WHEN vi.servicio_id IS NOT NULL THEN 'Servicio' ELSE 'Producto' END as tipo
        FROM venta_items vi
        JOIN ventas v ON vi.venta_id = v.id
        LEFT JOIN clientes c ON v.cliente_facturacion_id = c.id
        LEFT JOIN servicios s ON vi.servicio_id = s.id
        LEFT JOIN productos p ON vi.producto_id = p.id
        WHERE v.empleado_id = :uid 
        AND v.fecha_venta BETWEEN :start AND :end
        ORDER BY v.fecha_venta DESC
    """)
    
    try:
        rows = db.execute(query, {"uid": emp['id'], "start": start, "end": end}).fetchall()
        return [{
            "date": row.fecha_venta.strftime("%d/%m/%Y"),
            "client": f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip(),
            "receipt": f"{row.serie_comprobante or 'Tk'}-{row.numero_comprobante or '00'}",
            "item": row.item_nombre,
            "type": row.tipo,
            "price": float(row.precio or 0)
        } for row in rows]
    except Exception as e:
        print(f"Error Sales: {e}")
        return []

# ==========================================
# 4. REPORTES: COMISIONES Y PROPINAS
# ==========================================
@router.get("/reports/financial")
def get_financial_report(
    type: str, # 'commissions' o 'tips'
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    emp = get_logged_employee(db, current_user)
    start, end = get_date_range(start_date, end_date)
    
    data = []
    
    if type == 'commissions':
        query = text("""
            SELECT c.fecha_generacion as fecha, c.monto_comision as monto, c.estado,
                   s.nombre as concepto
            FROM comisiones c
            LEFT JOIN venta_items vi ON c.venta_item_id = vi.id
            LEFT JOIN servicios s ON vi.servicio_id = s.id
            WHERE c.empleado_id = :uid AND c.fecha_generacion BETWEEN :start AND :end
            ORDER BY c.fecha_generacion DESC
        """)
        rows = db.execute(query, {"uid": emp['id'], "start": start, "end": end}).fetchall()
        for row in rows:
            data.append({
                "date": row.fecha.strftime("%d/%m/%Y"),
                "concept": row.concepto or "Comisión Venta",
                "amount": float(row.monto or 0),
                "status": row.estado
            })
            
    elif type == 'tips':
        query = text("""
            SELECT fecha_registro, monto, metodo_pago, entregado_al_barbero
            FROM propinas
            WHERE empleado_id = :uid AND fecha_registro BETWEEN :start AND :end
            ORDER BY fecha_registro DESC
        """)
        rows = db.execute(query, {"uid": emp['id'], "start": start, "end": end}).fetchall()
        for row in rows:
            data.append({
                "date": row.fecha_registro.strftime("%d/%m/%Y"),
                "concept": f"Propina ({row.metodo_pago})",
                "amount": float(row.monto or 0),
                "status": "Pagado" if row.entregado_al_barbero else "Pendiente"
            })
            
    return data

# ==========================================
# 5. COMPLETAR CITA (FOTO)
# ==========================================
@router.post("/appointments/{appt_id}/complete")
async def complete_appointment(
    appt_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    emp = get_logged_employee(db, current_user) # Verifica que sea SU cita
    
    upload_dir = "uploads/evidence"
    os.makedirs(upload_dir, exist_ok=True)
    
    ext = file.filename.split(".")[-1]
    filename = f"evidencia_{appt_id}_{uuid.uuid4().hex[:8]}.{ext}"
    path = f"{upload_dir}/{filename}"
    
    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    public_url = f"/static/evidence/{filename}"
    
    try:
        # Solo permite actualizar si la cita pertenece al empleado logueado (ID 10)
        stmt = text("""
            UPDATE reservas 
            SET estado = 'Finalizado', evidencia_url = :url, fecha_actualizacion = NOW()
            WHERE id = :aid AND empleado_id = :uid
        """)
        result = db.execute(stmt, {"url": public_url, "aid": appt_id, "uid": emp['id']})
        db.commit()
        
        if result.rowcount == 0:
            raise HTTPException(status_code=404, detail="Cita no encontrada o no te pertenece")
            
        return {"message": "Evidencia subida correctamente", "url": public_url}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))