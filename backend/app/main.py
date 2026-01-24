from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sys

# --- IMPORTS DE RUTAS ---
# Vamos a usar un try/except para saber si aquí está fallando la importación
try:
    from app.routers import auth, staff, appointments
    print("✅ Módulos de rutas importados correctamente")
except ImportError as e:
    print(f"❌ ERROR CRÍTICO IMPORTANDO RUTAS: {e}")

app = FastAPI()

# --- CONFIGURACIÓN DE SEGURIDAD (CORS) ---
origins = [
    "http://localhost:3000",
    "http://localhost:8000",
    "https://staff.jvcorp.pe",
    "https://jv-staff-production.up.railway.app", # (Opcional)
    "https://celebrated-analysis-production.up.railway.app", # <--- NUEVO FRONTEND
    "*" 
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- CONEXIÓN DE RUTAS ---
# Usamos verificaciones para que no explote de golpe si falla el import
if 'auth' in locals():
    app.include_router(auth.router)
if 'staff' in locals():
    app.include_router(staff.router)       
if 'appointments' in locals():
    app.include_router(appointments.router)

@app.get("/")
def root():
    return {"message": "BarberStaff API is Online 🚀"}