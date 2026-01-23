import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# -----------------------------------------------------------------------------
# 1. DEFINICIÓN DE LA URL (Aquí estaba tu error de sintaxis)
# -----------------------------------------------------------------------------
# Asegúrate de que esta línea termine con comillas y paréntesis: ")
# Reemplaza el texto dentro de las segundas comillas con TU URL REAL de Railway.
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:JbCjfwFkrmmbuQdkFpCWGvNEbmqCUldc@gondola.proxy.rlwy.net:17823/railway")

# -----------------------------------------------------------------------------
# 2. EL PARCHE (Lo que me preguntaste) - DÉJALO ASÍ
# -----------------------------------------------------------------------------
if DATABASE_URL and DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# -----------------------------------------------------------------------------
# 3. CONFIGURACIÓN DE SQLALCHEMY
# -----------------------------------------------------------------------------
engine = create_engine(DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()