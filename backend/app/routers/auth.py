from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["Auth"])

class LoginRequest(BaseModel):
    email: str
    password: str

# Simulación de respuesta de Login
@router.post("/login")
def login(request: LoginRequest):
    # MODO DEV: Aceptamos cualquier cosa que no esté vacía
    if not request.email or not request.password:
        raise HTTPException(status_code=400, detail="Faltan datos")

    print(f"Login intentado por: {request.email}") # Ver esto en la terminal ayuda mucho

    return {
        "token": "fake-jwt-token-for-testing-12345",
        "user": {
            "id": 1,
            "name": "Barbero Tester",
            "email": request.email,
            "role": "staff",
            "photo_url": "https://i.pravatar.cc/300" 
        }
    }
