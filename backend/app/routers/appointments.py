from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.database import get_db
from app.routers.auth import get_current_user
import shutil
import os
from pathlib import Path
from uuid import uuid4

router = APIRouter(prefix="/staff/appointments", tags=["Staff Appointments"])

# Directorio para subir imágenes
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)

@router.get("/pending")
def get_pending_appointments(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Lista las citas pendientes del empleado actual.
    Filtra por:
    - estado: 'Programada'
    - fecha_hora_inicio: >= Hoy (NOW())
    """
    user_id = current_user.id

    query = text("""
        SELECT 
            r.id, 
            r.fecha_hora_inicio, 
            r.estado,
            c.nombres || ' ' || c.apellidos as cliente_nombre,
            s.nombre as servicio_nombre,
            r.notas_internas
        FROM reservas r
        LEFT JOIN clientes c ON r.cliente_id = c.id
        LEFT JOIN servicios s ON r.servicio_id = s.id
        WHERE r.empleado_id = :uid
        AND r.estado = 'Programada'
        AND r.fecha_hora_inicio >= NOW()::date
        ORDER BY r.fecha_hora_inicio ASC
    """)
    
    # NOTA: Usamos NOW()::date para incluir todas las de hoy, incluso si la hora ya pasó (opcional)
    # Si quieres estricto futuro: NOW()
    
    try:
        results = db.execute(query, {"uid": user_id}).fetchall()
        
        appointments = []
        for row in results:
            appointments.append({
                "id": row.id,
                "date_time": row.fecha_hora_inicio,
                "status": row.estado,
                "client_name": row.cliente_nombre or "Cliente Desconocido",
                "service_name": row.servicio_nombre or "Servicio General",
                "notes": row.notas_internas
            })
            
        return appointments

    except Exception as e:
        print(f"Error fetching appointments: {e}")
        raise HTTPException(status_code=500, detail="Error al obtener citas")

@router.post("/{appointment_id}/complete")
async def complete_appointment(
    appointment_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """
    Marca una cita como finalizada y sube una foto de evidencia.
    """
    try:
        # Generar nombre único para el archivo
        file_ext = file.filename.split(".")[-1]
        file_name = f"{uuid4()}.{file_ext}"
        file_path = UPLOAD_DIR / file_name
        
        # Guardar archivo
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # URL relativa (asumiendo que se servirá 'uploads' como estático)
        file_url = f"/uploads/{file_name}"

        # Actualizar BD
        update_query = text("""
            UPDATE reservas
            SET estado = 'Finalizado',
                notas_internas = COALESCE(notas_internas, '') || ' [Evidencia: ' || :url || ']'
            WHERE id = :aid AND empleado_id = :uid
            RETURNING id
        """)
        
        result = db.execute(update_query, {
            "url": file_url,
            "aid": appointment_id,
            "uid": current_user.id
        })
        db.commit()

        if not result.fetchone():
            raise HTTPException(status_code=404, detail="Cita no encontrada o no pertenece al usuario")

        return {"message": "Cita completada exitosamente", "evidence_url": file_url}

    except Exception as e:
        db.rollback()
        print(f"Error completing appointment: {e}")
        raise HTTPException(status_code=500, detail=f"Error al completar cita: {str(e)}")