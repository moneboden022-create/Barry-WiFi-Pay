# backend/src/db.py
import os
import logging
from pathlib import Path
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import OperationalError

from dotenv import load_dotenv

# =============================================================
# CHARGER VARIABLES D'ENVIRONNEMENT
# =============================================================
load_dotenv()

logger = logging.getLogger("uvicorn.error")

# =============================================================
# CONFIG - URL DB
# =============================================================
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./barry_wifi.db"  # fallback dev
)

# Si SQLite, s'assurer que le dossier existe
if DATABASE_URL.startswith("sqlite"):
    db_path = DATABASE_URL.replace("sqlite:///", "")
    db_dir = Path(db_path).parent
    db_dir.mkdir(parents=True, exist_ok=True)

# =============================================================
# ENGINE
# =============================================================
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True,   # important : teste la connexion avant chaque requête
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()

# =============================================================
# TEST AUTOMATIQUE DE LA DB AU DÉMARRAGE
# =============================================================
def test_database_connection():
    try:
        with engine.connect() as conn:
            conn.execute("SELECT 1")
        logger.info("✅ Connexion DB OK : %s", DATABASE_URL)
    except OperationalError as e:
        logger.error("❌ Erreur connexion DB : %s", e)

# Appeler le test immédiatement
test_database_connection()

# =============================================================
# DÉPENDANCE FASTAPI
# =============================================================
def get_db():
    db = SessionLocal()
    try:
        yield db
    except Exception as e:
        logger.error("DB ERROR: %s", e)
        raise
    finally:
        db.close()
