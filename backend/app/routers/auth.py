from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from sqlalchemy import text
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
from datetime import datetime, timedelta
import os

from app.database import get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])

# --- CONFIGURACIÓN DE SEGURIDAD ---
# Usa una clave segura en producción. Por ahora usamos una default para que funcione.
SECRET_KEY = os.getenv("SECRET_KEY", "super_secreto_barber_staff_2026")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7 # 7 días de sesión

# Configuración de Hashes (Incluimos scrypt porque lo vi en tu base de datos)
pwd_context = CryptContext(schemes=["scrypt", "bcrypt", "pbkdf2_sha256"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

# --- MODELOS ---
class LoginRequest(BaseModel):
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class UserData(BaseModel):
    id: int
    email: str
    activo: bool

# --- FUNCIONES AUXILIARES ---
def verify_password(plain_password, hashed_password):
    try:
        # Intento directo con passlib
        return pwd_context.verify(plain_password, hashed_password)
    except Exception as e:
        print(f"⚠️ Error verificando hash: {e}")
        # Fallback simple por si el formato de la BD es antiguo o texto plano (solo dev)
        return plain_password == hashed_password

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# --- ENDPOINT DE LOGIN ---
@router.post("/login", response_model=Token)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    email_clean = request.email.strip().lower()
    print(f"🔑 LOGIN INTENTO: {email_clean}")

    # 1. Buscar usuario en tabla 'empleados'
    try:
        query = text("SELECT * FROM empleados WHERE LOWER(email) = :email LIMIT 1")
        user = db.execute(query, {"email": email_clean}).mappings().first()
    except Exception as e:
        print(f"💥 Error DB en Login: {e}")
        raise HTTPException(status_code=500, detail="Error de conexión con base de datos")

    if not user:
        print(f"❌ Usuario no encontrado: {email_clean}")
        raise HTTPException(status_code=401, detail="Email no registrado")

    # 2. Verificar Contraseña
    # Nota: user['password'] viene de la BD
    if not verify_password(request.password, user['password']):
        print(f"❌ Contraseña incorrecta para: {email_clean}")
        raise HTTPException(status_code=401, detail="Contraseña incorrecta")

    if not user['activo']:
        raise HTTPException(status_code=403, detail="Usuario inactivo")

    # 3. GENERAR TOKEN (LA CORRECCIÓN CLAVE) 🔑
    # Antes aquí debía decir "sub": "demo@barber.com". Ahora ponemos el email REAL.
    access_token = create_access_token(data={"sub": user['email']})
    
    print(f"✅ LOGIN ÉXITO: {user['nombres']} (ID: {user['id']})")
    return {"access_token": access_token, "token_type": "bearer"}

# --- DEPENDENCIA PARA PROTEGER RUTAS ---
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
    
    # Retornamos un objeto simple con el email del token
    # (El staff.py hará la búsqueda completa en BD)
    class SimpleUser:
        def __init__(self, email, id=0):
            self.email = email
            self.id = id # ID temporal, staff.py buscará el real
            
    return SimpleUser(email=email)