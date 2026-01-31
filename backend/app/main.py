from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
# 1. IMPORTANTE: Importar el Middleware
from fastapi.middleware.cors import CORSMiddleware 
import os

from app.routers import auth, staff, appointments
from app.database import Base, engine

# Crear tablas
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="BarberStaff API",
    description="API para gestión de staff",
    version="1.0.0"
)

# -----------------------------------------------------------------------------
# 2. CONFIGURACIÓN DE CORS (La Solución)
# -----------------------------------------------------------------------------
# Esto le dice al navegador: "Acepto peticiones de cualquier sitio web"
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # El asterisco "*" significa "TODOS"
    allow_credentials=True,
    allow_methods=["*"],  # Permitir GET, POST, PUT, DELETE, etc.
    allow_headers=["*"],  # Permitir todos los headers (incluyendo Authorization)
)
# -----------------------------------------------------------------------------

# Configurar carpeta de imágenes
os.makedirs("uploads", exist_ok=True)
app.mount("/static", StaticFiles(directory="uploads"), name="static")

# Rutas
app.include_router(auth.router)
app.include_router(staff.router)
app.include_router(appointments.router)

@app.get("/")
def read_root():
    return {"message": "Sistema BarberStaff Online 🚀"}