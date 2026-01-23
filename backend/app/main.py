from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# --- AQUÍ ESTABA EL ERROR: Importamos explícitamente los 3 módulos ---
from app.routers import auth, staff, appointments 

app = FastAPI()

# Configuración de CORS (Crucial para que Chrome no bloquee la app)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción esto se cambia, pero en dev usamos *
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Conectamos las rutas al servidor ---
app.include_router(auth.router)
app.include_router(staff.router)        # Ahora sí funcionará porque staff está importado arriba
app.include_router(appointments.router)

@app.get("/")
def root():
    return {"message": "BarberStaff API is Online 🚀"}
