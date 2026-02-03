from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy import text
from jose import JWTError, jwt
from pydantic import BaseModel
from datetime import datetime, timedelta
import os

# 1. IMPORTANTE: Importamos la herramienta para leer tus contraseñas específicas
from werkzeug.security import check_password_hash 
from app.database import get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])

# --- CONFIGURACIÓN ---
SECRET_KEY = os.getenv("SECRET_KEY", "super_secreto_barber_staff_2026")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7 

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

class LoginRequest(BaseModel):
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

# --- FUNCIÓN DE VERIFICACIÓN (LA SOLUCIÓN) ---
def verify_password(plain_password, hashed_password):
    """
    Verifica la contraseña soportando el formato 'scrypt:32768:8:1...'
    usado por Werkzeug/Odoo/Flask.
    """
    try:
        # Werkzeug maneja automáticamente el formato scrypt raro de tu BD
        return check_password_hash(hashed_password, plain_password)
    except Exception as e:
        print(f"⚠️ Error Werkzeug: {e}")
        # Fallback de emergencia por si alguna pass es texto plano (solo dev)
        return plain_password == hashed_password

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# --- LOGIN ---
@router.post("/login", response_model=Token)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    # Limpiamos el email (minúsculas y sin espacios)
    email_clean = request.email.strip().lower()
    print(f"🔑 LOGIN INTENTO: {email_clean}")

    # 1. Buscar usuario
    try:
        query = text("SELECT * FROM empleados WHERE LOWER(email) = :email LIMIT 1")
        user = db.execute(query, {"email": email_clean}).mappings().first()
    except Exception as e:
        print(f"💥 Error DB: {e}")
        raise HTTPException(status_code=500, detail="Error de base de datos")

    if not user:
        print(f"❌ Usuario no encontrado: {email_clean}")
        raise HTTPException(status_code=401, detail="Email no registrado")

    # 2. Verificar Contraseña con la nueva función
    if not verify_password(request.password, user['password']):
        print(f"❌ Contraseña incorrecta para: {email_clean}")
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    if not user['activo']:
        raise HTTPException(status_code=403, detail="Usuario inactivo")

    # 3. Generar Token con el Email Real
    access_token = create_access_token(data={"sub": user['email']})
    
    print(f"✅ LOGIN ÉXITO: {user['nombres']} (ID: {user['id']})")
    return {"access_token": access_token, "token_type": "bearer"}

# --- DEPENDENCIA ---
def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudieron validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    class SimpleUser:
        def __init__(self, email):
            self.email = email
            self.id = 0 
            
    return SimpleUser(email=email)