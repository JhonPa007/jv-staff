from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, staff, appointments

app = FastAPI()

# --- CONFIGURACIÓN DE SEGURIDAD (CORS) ---
origins = [
    "http://localhost:3000",
    "http://localhost:8000",
    "https://staff.jvcorp.pe",  # Tu Frontend
    "*" 
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Conectamos las rutas al servidor ---
# Ahora sí funcionará porque ya los importamos arriba
app.include_router(auth.router)
app.include_router(staff.router)       
app.include_router(appointments.router)

@app.get("/")
def root():
    return {"message": "BarberStaff API is Online 🚀"}
