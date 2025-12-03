# backend/src/db.py
import os
import logging
from pathlib import Path
from sqlalchemy import create_engine, event, text
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import OperationalError, IntegrityError

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
            conn.execute(text("SELECT 1"))
        logger.info("✅ Connexion DB OK : %s", DATABASE_URL)
        return True
    except OperationalError as e:
        logger.error("❌ Erreur connexion DB : %s", e)
        return False

# Appeler le test immédiatement
test_database_connection()


# =============================================================
# CRÉATION SÉCURISÉE DES TABLES
# =============================================================
def create_tables_safely():
    """
    Crée les tables de manière sécurisée.
    Gère les erreurs d'index déjà existants (SQLite).
    """
    try:
        # Importer les modèles pour les enregistrer
        from . import models
        
        # Créer les tables avec checkfirst=True
        Base.metadata.create_all(bind=engine, checkfirst=True)
        logger.info("✅ Tables créées/vérifiées avec succès")
        return True
    except OperationalError as e:
        error_msg = str(e)
        # Ignorer les erreurs d'index déjà existant
        if "already exists" in error_msg or "index" in error_msg.lower():
            logger.warning("⚠️ Index déjà existant (ignoré) : %s", error_msg[:100])
            return True
        logger.error("❌ Erreur création tables : %s", e)
        return False
    except IntegrityError as e:
        logger.warning("⚠️ Erreur d'intégrité (ignorée) : %s", str(e)[:100])
        return True
    except Exception as e:
        logger.error("❌ Erreur inattendue création tables : %s", e)
        return False


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


# =============================================================
# RESET DATABASE (pour dev/test uniquement)
# =============================================================
def reset_database():
    """
    Supprime et recrée toutes les tables.
    ⚠️ ATTENTION : Perte de toutes les données !
    """
    try:
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)
        logger.info("✅ Base de données réinitialisée")
        return True
    except Exception as e:
        logger.error("❌ Erreur reset DB : %s", e)
        return False
