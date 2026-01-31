from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel

router = APIRouter(prefix="/auth", tags=["Auth"])

# --- ESQUEMAS ---
class LoginRequest(BaseModel):
    email: str
    password: str

# --- MOCK USER (Para evitar romper staff.py) ---
class MockUser:
    def __init__(self, id, email, first_name):
        self.id = id
        self.email = email
        self.first_name = first_name

# --- DEPENDENCIAS ---
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    # MODO DEV: Retornamos siempre el mismo usuario "logueado"
    # En producción, aquí validaríamos el JWT
    return MockUser(id=1, email="demo@barber.com", first_name="Barbero Demo")

# --- ENDPOINTS ---
@router.post("/login")
def login(request: LoginRequest):
    # MODO DEV: Aceptamos cualquier cosa que no esté vacía
    if not request.email or not request.password:
        raise HTTPException(status_code=400, detail="Faltan datos")

    print(f"Login intentado por: {request.email}") 

    return {
        "access_token": "fake-jwt-token-for-testing-12345", 
        "token": "fake-jwt-token-for-testing-12345", # Para compatibilidad si el front lo busca así
        "token_type": "bearer",
        "user": {
            "id": 1,
            "name": "Barbero Demo",
            "email": request.email,
            "role": "staff",
            "photo_url": "https://i.pravatar.cc/300" 
        }
    }
