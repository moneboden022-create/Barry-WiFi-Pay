# backend/src/security.py
from datetime import datetime, timedelta
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, HTTPBearer, HTTPAuthorizationCredentials
from passlib.context import CryptContext
from jose import jwt, JWTError
from sqlalchemy.orm import Session

from .db import get_db
from . import models

# load env safely
from dotenv import load_dotenv
import os
load_dotenv()

# ============================================================
# CONFIG (lire depuis .env en priorité)
# ============================================================
SECRET_KEY = os.getenv("SECRET_KEY", "BARRY_SUPER_SECRET_KEY_CHANGE_ME_64_CHARS")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

# Token access par défaut 7 jours (modifiable via .env)
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60 * 24 * 7))
# Refresh token par défaut 30 jours
REFRESH_TOKEN_EXPIRE_DAYS = int(os.getenv("REFRESH_TOKEN_EXPIRE_DAYS", 30))

# ============================================================
# SCHEMES
# ============================================================
bearer_scheme = HTTPBearer()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/oauth-login")

# ============================================================
# HASH (Argon2 recommandé)
# ============================================================
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")


# ============================================================
# PASSWORD HELPERS
# ============================================================
def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


# ============================================================
# TOKEN CREATION / VALIDATION
# ============================================================
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Génère un token JWT d'accès.
    data doit contenir au minimum {'sub': phone, 'uid': user_id}
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Génère un refresh token (type=refresh). Stocke côté client et/ou DB si tu veux revocation.
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS))
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalide ou expiré")


# ============================================================
# UTILITAIRES DB - USERS
# ============================================================
def get_user_by_phone(db: Session, phone_number: str) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.phone_number == phone_number).first()


def get_user_by_id(db: Session, user_id: int) -> Optional[models.User]:
    return db.query(models.User).filter(models.User.id == user_id).first()


# ============================================================
# DEPENDENCY : GET CURRENT USER (TOKEN -> SQLA User)
# ============================================================
async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db)
) -> models.User:
    token = credentials.credentials

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token invalide ou expiré.",
        headers={"WWW-Authenticate": "Bearer"},
    )

    payload = None
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        raise credentials_exception

    # Vérifier type token (doit être access)
    token_type = payload.get("type")
    if token_type != "access":
        raise credentials_exception

    phone = payload.get("sub")
    uid = payload.get("uid")
    if phone is None or uid is None:
        raise credentials_exception

    user = db.query(models.User).filter(models.User.id == uid, models.User.phone_number == phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")

    # Optionnel : vérifier que le user est actif
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Compte inactif")

    return user
