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

# --- UTILIDADES ---
def get_peru_now():
    return datetime.utcnow() - timedelta(hours=5)

def get_date_range(start_date: Optional[date], end_date: Optional[date]):
    today = get_peru_now().date()
    if not start_date:
        start_date = date(today.year, today.month, 1)
    if not end_date:
        if today.month == 12:
            end_date = date(today.year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(today.year, today.month + 1, 1) - timedelta(days=1)
    return start_date, end_date

# --- HELPER: BÚSQUEDA DIAGNÓSTICA ---
def get_logged_employee(db: Session, current_user: dict):
    # 1. Limpiamos el email del token (Login)
    email_token = current_user.email.strip().lower()
    print(f"🕵️‍♂️ BUSCANDO EN BD EL EMAIL: '{email_token}'")

    try:
        # 2. Buscamos coincidencia exacta en minúsculas
        query = text("SELECT * FROM empleados WHERE LOWER(email) = :email LIMIT 1")
        employee = db.execute(query, {"email": email_token}).mappings().first()
        
        if employee:
            print(f"✅ ENCONTRADO: ID={employee['id']}, Nombre={employee['nombres']}")
            return employee
        else:
            print(f"❌ NO ENCONTRADO. El email '{email_token}' no está en la tabla 'empleados'.")
            return None
            
    except Exception as e:
        print(f"💥 ERROR SQL: {e}")
        return None

# ==========================================
# 1. DASHBOARD
# ==========================================
@router.get("/dashboard")
def get_dashboard(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    start, end = get_date_range(start_date, end_date)
    
    # 1. Intentamos obtener al empleado real (Renato - ID 5)
    emp = get_logged_employee(db, current_user)
    
    if emp:
        # CASO ÉXITO: Usamos el ID 5
        uid = emp['id']
        first_name = emp['nombres'].split()[0].title()
        # 🔥 AQUÍ ESTÁ LO QUE PEDISTE: Mostramos el ID en el nombre
        user_name_display = f"{first_name} (ID: {uid})"
    else:
        # CASO FALLO: Usamos el ID del Token (probablemente ID de Auth)
        uid = current_user.id
        user_name_display = f"Demo (ID Token: {uid})"
        print(f"⚠️ Usando modo Demo con ID {uid} porque no se encontró el empleado.")

    print(f"📊 CALCULANDO MÉTRICAS PARA ID: {uid} entre {start} y {end}")

    # 2. PRODUCCIÓN
    try:
        query_prod = text("""
            SELECT COALESCE(SUM(vi.subtotal_item_neto), 0)
            FROM venta_items vi
            JOIN ventas v ON vi.venta_id = v.id
            WHERE v.empleado_id = :uid
            AND vi.servicio_id IS NOT NULL
            AND v.fecha_venta BETWEEN :start AND :end
        """)
        production = db.execute(query_prod, {"uid": uid, "start": start, "end": end}).scalar() or 0
    except Exception as e:
        print(f"Error Prod: {e}")
        production = 0

    # 3. COMISIONES
    try:
        query_com = text("SELECT COALESCE(SUM(monto_comision), 0) FROM comisiones WHERE empleado_id = :uid AND estado = 'Pendiente'")
        pending = db.execute(query_com, {"uid": uid}).scalar() or 0
    except:
        pending = 0

    # 4. PRÓXIMA CITA
    next_appt = None
    try:
        query_next = text("""
            SELECT r.fecha_hora_inicio, s.nombre, c.razon_social_nombres, c.apellidos
            FROM reservas r
            LEFT JOIN servicios s ON r.servicio_id = s.id
            LEFT JOIN clientes c ON r.cliente_id = c.id
            WHERE r.empleado_id = :uid 
            AND r.estado = 'Programada'
            ORDER BY r.fecha_hora_inicio ASC LIMIT 1
        """)
        row = db.execute(query_next, {"uid": uid}).first()
        if row:
            client = f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip() or "Cliente"
            next_appt = {
                "time": row.fecha_hora_inicio.strftime("%d/%m %H:%M"),
                "client": client, 
                "service": row.nombre or "Servicio"
            }
    except:
        pass

    meses = {1:"Enero", 2:"Febrero", 3:"Marzo", 4:"Abril", 5:"Mayo", 6:"Junio", 7:"Julio", 8:"Agosto", 9:"Septiembre", 10:"Octubre", 11:"Noviembre", 12:"Diciembre"}
    periodo = f"{meses.get(start.month)} {start.year}"

    return {
        "period": periodo,
        "user_name": user_name_display, # Aquí va el nombre con ID
        "metrics": {"total_production": float(production), "total_commission_pending": float(pending), "total_commission_paid": 0.0, "rating": 5.0, "completed_services": 0},
        "next_appointment": next_appt
    }

# ==========================================
# 2. LISTADO DE CITAS
# ==========================================
@router.get("/appointments")
def get_appointments(status: Optional[str] = None, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    # Lógica idéntica para obtener ID
    emp = get_logged_employee(db, current_user)
    uid = emp['id'] if emp else current_user.id
    
    sql = """
        SELECT r.id, r.fecha_hora_inicio, r.estado, r.evidencia_url,
               s.nombre as servicio, c.razon_social_nombres, c.apellidos, c.telefono
        FROM reservas r
        LEFT JOIN servicios s ON r.servicio_id = s.id
        LEFT JOIN clientes c ON r.cliente_id = c.id
        WHERE r.empleado_id = :uid
    """
    if status == 'Programada': sql += " AND r.estado = 'Programada'"
    elif status: sql += " AND r.estado = :status"
    
    sql += " ORDER BY r.fecha_hora_inicio ASC"
    
    try:
        rows = db.execute(text(sql), {"uid": uid, "status": status}).fetchall()
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

# ... El resto de endpoints (complete, reports) usarán la misma lógica ...
@router.post("/appointments/{appt_id}/complete")
async def complete_appointment(appt_id: int, file: UploadFile = File(...), db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    emp = get_logged_employee(db, current_user)
    uid = emp['id'] if emp else current_user.id
    
    os.makedirs("uploads/evidence", exist_ok=True)
    filename = f"evidencia_{appt_id}_{uuid.uuid4().hex[:8]}.{file.filename.split('.')[-1]}"
    with open(f"uploads/evidence/{filename}", "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    
    url = f"/static/evidence/{filename}"
    
    try:
        stmt = text("UPDATE reservas SET estado = 'Finalizado', evidencia_url = :url WHERE id = :aid AND empleado_id = :uid")
        res = db.execute(stmt, {"url": url, "aid": appt_id, "uid": uid})
        db.commit()
        if res.rowcount == 0: raise HTTPException(404, "Cita no encontrada")
        return {"message": "OK", "url": url}
    except Exception as e:
        db.rollback()
        raise HTTPException(500, str(e))

@router.get("/reports/sales")
def get_sales_report(start_date: Optional[date] = None, end_date: Optional[date] = None, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    emp = get_logged_employee(db, current_user)
    uid = emp['id'] if emp else current_user.id
    start, end = get_date_range(start_date, end_date)
    
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
        rows = db.execute(query, {"uid": uid, "start": start, "end": end}).fetchall()
        return [{
            "date": row.fecha_venta.strftime("%d/%m/%Y"),
            "client": f"{row.razon_social_nombres or ''} {row.apellidos or ''}".strip(),
            "receipt": f"{row.serie_comprobante or 'Tk'}-{row.numero_comprobante or '00'}",
            "item": row.item_nombre,
            "type": row.tipo,
            "price": float(row.precio or 0)
        } for row in rows]
    except:
        return []

@router.get("/reports/financial")
def get_financial_report(type: str, start_date: Optional[date] = None, end_date: Optional[date] = None, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    emp = get_logged_employee(db, current_user)
    uid = emp['id'] if emp else current_user.id
    start, end = get_date_range(start_date, end_date)
    data = []
    if type == 'commissions':
        query = text("""
            SELECT c.fecha_generacion as fecha, c.monto_comision as monto, c.estado, s.nombre as concepto
            FROM comisiones c
            LEFT JOIN venta_items vi ON c.venta_item_id = vi.id
            LEFT JOIN servicios s ON vi.servicio_id = s.id
            WHERE c.empleado_id = :uid AND c.fecha_generacion BETWEEN :start AND :end ORDER BY c.fecha_generacion DESC
        """)
        rows = db.execute(query, {"uid": uid, "start": start, "end": end}).fetchall()
        for row in rows:
            data.append({"date": row.fecha.strftime("%d/%m/%Y"), "concept": row.concepto or "Comisión", "amount": float(row.monto or 0), "status": row.estado})
    elif type == 'tips':
        query = text("SELECT fecha_registro, monto, metodo_pago, entregado_al_barbero FROM propinas WHERE empleado_id = :uid AND fecha_registro BETWEEN :start AND :end ORDER BY fecha_registro DESC")
        rows = db.execute(query, {"uid": uid, "start": start, "end": end}).fetchall()
        for row in rows:
            data.append({"date": row.fecha_registro.strftime("%d/%m/%Y"), "concept": f"Propina ({row.metodo_pago})", "amount": float(row.monto or 0), "status": "Pagado" if row.entregado_al_barbero else "Pendiente"})
    return data