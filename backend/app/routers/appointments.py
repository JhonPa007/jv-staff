from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import Reserva # Importamos el modelo real

router = APIRouter(prefix="/appointments", tags=["Appointments"])

class AppointmentFinishRequest(BaseModel):
    evidence_url: str

@router.post("/{appointment_id}/finalize")
def finalize_appointment(
    appointment_id: int, 
    request: AppointmentFinishRequest, 
    db: Session = Depends(get_db)
):
    print(f"--> Buscando Reserva ID: {appointment_id} en Postgres...")

    # 1. Buscamos en la tabla 'reservas'
    reserva = db.query(Reserva).filter(Reserva.id == appointment_id).first()

    if not reserva:
        # IMPORTANTE: Si estás probando con un ID que no existe en tu ERP,
        # esto fallará. Asegúrate de usar un ID real de tu tabla reservas.
        raise HTTPException(status_code=404, detail="Reserva no encontrada en el ERP")

    # 2. Actualizamos los datos
    # Guardamos la URL de la foto en 'notas_internas'
    nota_actual = reserva.notas_internas or ""
    reserva.notas_internas = f"{nota_actual} [EVIDENCIA: {request.evidence_url}]"
    
    # Cambiamos estado (Asegúrate que este estado sea válido en tu ERP)
    reserva.estado = "completada" 
    
    # Definimos precio (Aquí podrías traer el precio del servicio_id si mapearas esa tabla)
    # Por ahora simulamos un precio fijo para cerrar la caja
    reserva.precio_cobrado = 30.00 

    # 3. Guardar en DB
    db.commit()
    db.refresh(reserva)
    
    print(f"--> ÉXITO: Reserva {appointment_id} actualizada.")
    
    return {
        "status": "success",
        "message": "Sincronizado con ERP",
        "data": {
            "id": reserva.id,
            "estado": reserva.estado,
            "evidencia_guardada_en": "notas_internas"
        }
    }