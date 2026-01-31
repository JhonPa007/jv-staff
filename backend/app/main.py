from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
# 1. IMPORTANTE: Importamos el manejador de CORS
from fastapi.middleware.cors import CORSMiddleware 
import os

from app.routers import auth, staff, appointments
from app.database import Base, engine

# Crear tablas al inicio
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="BarberStaff API",
    description="API para gestión de staff de barbería",
    version="1.0.0"
)

# --------------------------------------------------------------------------
# 2. CONFIGURACIÓN DE CORS (El "Portero")
# --------------------------------------------------------------------------
# Esto permite que tu Frontend (Flutter Web) hable con este Backend
origins = [
    "*", # ⚠️ POR AHORA: Permitimos a TODOS (para que funcione ya)
    # En el futuro, pondremos aquí solo tu dominio:
    # "https://celebrated-analysis-production.up.railway.app",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"], # Permitir GET, POST, PUT, DELETE
    allow_headers=["*"], # Permitir enviar Tokens de Auth
)
# --------------------------------------------------------------------------

# Montar carpeta para imágenes (Evidencias)
os.makedirs("uploads", exist_ok=True)
app.mount("/static", StaticFiles(directory="uploads"), name="static")

# Registrar Rutas
app.include_router(auth.router)
app.include_router(staff.router)
app.include_router(appointments.router)

@app.get("/")
def read_root():
    return {"message": "Sistema BarberStaff Online 🚀"}