import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Chargement des variables d'environnement (.env)
DB_USER = os.getenv("POSTGRES_USER", "postgres")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "barrywifi")
DB_NAME = os.getenv("POSTGRES_DB", "barry_paywifi")
DB_HOST = os.getenv("POSTGRES_HOST", "db")
DB_PORT = os.getenv("POSTGRES_PORT", "5432")

# ✅ Nouveau driver psycopg (plus rapide et compatible SQLAlchemy 2.0)
DATABASE_URL = f"postgresql+psycopg://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Création de l’engine SQLAlchemy
engine = create_engine(DATABASE_URL, future=True, echo=False)

# Création de la session
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, future=True)

# Base pour les modèles
Base = declarative_base()
