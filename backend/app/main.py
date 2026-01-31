from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import os

from app.routers import auth, staff, appointments
from app.database import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI(title="BarberStaff API")

# -----------------------------------------------------------------------------
# CONFIGURACIÓN DE CORS (ESPECÍFICA)
# -----------------------------------------------------------------------------
origins = [
    "http://localhost:3000",  # Para cuando pruebas en tu PC
    "https://celebrated-analysis-production.up.railway.app", # <--- TU FRONTEND EXACTO
    # Nota: Asegúrate de NO poner una barra "/" al final de la URL
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,    # Usamos la lista específica
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# -----------------------------------------------------------------------------

os.makedirs("uploads", exist_ok=True)
app.mount("/static", StaticFiles(directory="uploads"), name="static")

app.include_router(auth.router)
app.include_router(staff.router)
app.include_router(appointments.router)

@app.get("/")
def read_root():
    return {"message": "Sistema BarberStaff Online 🚀"}