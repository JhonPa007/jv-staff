from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
# ... tus otros imports ...

app = FastAPI()

# --- CONFIGURACIÓN DE SEGURIDAD (CORS) ---
origins = [
    "http://localhost:3000",
    "http://localhost:8000",
    "https://staff.jvcorp.pe",  # <--- ¡TU DOMINIO DEL FRONTEND!
    "*" # Comodín (Permite todo, útil para pruebas)
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins, # Aquí autorizamos a tu App
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
