from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.database import Base

# --- TABLA: empleados ---
class Empleado(Base):
    __tablename__ = "empleados"

    # Mapeamos solo las columnas que necesitamos para el Login y Perfil
    id = Column(Integer, primary_key=True, index=True)
    nombres = Column(String)
    apellidos = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    # rol_id = Column(Integer) # Descomentar si usaremos roles luego
    
    # Relación (opcional, ayuda a navegar)
    reservas = relationship("Reserva", back_populates="empleado")

# --- TABLA: reservas ---
class Reserva(Base):
    __tablename__ = "reservas"

    id = Column(Integer, primary_key=True, index=True)
    
    # Llaves foráneas
    empleado_id = Column(Integer, ForeignKey("empleados.id"))
    # cliente_id = Column(Integer) # Mapear si tienes tabla clientes
    
    # Datos de la cita
    fecha_hora_inicio = Column(DateTime)
    fecha_hora_fin = Column(DateTime)
    estado = Column(String) # Ej: 'pendiente', 'completado'
    
    # Dinero
    precio_cobrado = Column(Float, nullable=True)
    
    # Usaremos 'notas_internas' para guardar la URL de la foto de evidencia
    notas_internas = Column(String, nullable=True) 
    
    # Relación inversa
    empleado = relationship("Empleado", back_populates="reservas")