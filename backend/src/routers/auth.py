from fastapi import (
    APIRouter, Depends, HTTPException, status,
    Request, UploadFile, File, Form, Body
)
from fastapi.security import OAuth2PasswordRequestForm, HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional, Union
import uuid
import shutil
from pathlib import Path
from sqlalchemy import func

from ..db import get_db
from .. import models, schemas
from ..security import (
    verify_password,
    hash_password,
    create_access_token,
    create_refresh_token,
    decode_token,
    get_current_user as secure_get_current_user,
    ACCESS_TOKEN_EXPIRE_MINUTES
)
from ..utils import (
    get_user_by_phone,
    get_user_by_identifier,
    get_or_create_device,
    cleanup_old_devices,
    count_user_devices,
    generate_otp
)

router = APIRouter(prefix="/auth", tags=["Auth"])


# ======================================================
# DOSSIER AVATARS
# ======================================================
AVATAR_DIR = Path("uploads/avatars")
AVATAR_DIR.mkdir(parents=True, exist_ok=True)


# ======================================================
# REGISTER (JSON - Pour Flutter)
# ======================================================
@router.post("/register", response_model=schemas.RegisterResponse)
async def register_user_json(
    data: schemas.RegisterRequest,
    db: Session = Depends(get_db)
):
    """
    Inscription via JSON (utilisé par Flutter).
    Accepte: first_name, last_name, phone_number, country, password, isBusiness, avatar
    """
    # Vérifier numéro existant
    existing = get_user_by_phone(db, data.phone_number)
    if existing:
        raise HTTPException(status_code=400, detail="Ce numéro est déjà utilisé.")

    # Créer user
    user = models.User(
        first_name=data.first_name,
        last_name=data.last_name,
        phone_number=data.phone_number,
        country=data.country,
        isBusiness=data.isBusiness,
        hashed_password=hash_password(data.password),
        avatar=data.avatar,
        max_devices_allowed=10 if data.isBusiness else 3,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    # Générer tokens
    payload = {"sub": user.phone_number, "uid": user.id}
    access = create_access_token(payload)
    refresh = create_refresh_token(payload)

    return schemas.RegisterResponse(
        access_token=access,
        refresh_token=refresh,
        token_type="bearer",
        user=schemas.UserOut.from_orm(user)
    )


# ======================================================
# REGISTER (FormData + Avatar - Alternative)
# ======================================================
@router.post("/register/multipart", response_model=schemas.RegisterResponse)
async def register_user_multipart(
    first_name: str = Form(...),
    last_name: str = Form(...),
    phone_number: str = Form(...),
    country: str = Form(...),
    password: str = Form(...),
    isBusiness: bool = Form(False),
    avatar: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    """
    Inscription via FormData avec upload d'avatar.
    Alternative pour les clients qui veulent envoyer un fichier avatar.
    """
    # Vérifier numéro existant
    existing = get_user_by_phone(db, phone_number)
    if existing:
        raise HTTPException(status_code=400, detail="Ce numéro est déjà utilisé.")

    # Upload avatar
    avatar_url = None
    if avatar:
        ext = avatar.filename.split('.')[-1] if avatar.filename else "png"
        file_name = f"{uuid.uuid4()}.{ext}"
        file_path = AVATAR_DIR / file_name

        with open(file_path, "wb") as f:
            shutil.copyfileobj(avatar.file, f)

        avatar_url = f"/static/avatars/{file_name}"

    # Créer user
    user = models.User(
        first_name=first_name,
        last_name=last_name,
        phone_number=phone_number,
        country=country,
        isBusiness=isBusiness,
        hashed_password=hash_password(password),
        avatar=avatar_url,
        max_devices_allowed=10 if isBusiness else 3,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    # Générer tokens
    payload = {"sub": user.phone_number, "uid": user.id}
    access = create_access_token(payload)
    refresh = create_refresh_token(payload)

    return schemas.RegisterResponse(
        access_token=access,
        refresh_token=refresh,
        token_type="bearer",
        user=schemas.UserOut.from_orm(user)
    )


# ======================================================
# LOGIN (multi-device, jwt) - Compatible Flutter
# ======================================================
@router.post("/login", response_model=schemas.LoginResponse)
def login(request: Request, user_in: schemas.UserLogin, db: Session = Depends(get_db)):
    """
    🔥 Connexion utilisateur unifiée.
    Accepte: identifier (email OU téléphone) + password
    Formats supportés: "620035847", "+224620035847", "user@gmail.com"
    Retourne: access_token, refresh_token, token_type, user
    """
    # Récupérer l'identifiant (identifier > phone_number > phone)
    identifier = user_in.get_identifier()
    if not identifier:
        raise HTTPException(400, "Identifiant requis (email ou téléphone).")

    # 🔍 Recherche par identifier (email ou téléphone)
    user = get_user_by_identifier(db, identifier)
    if not user:
        raise HTTPException(401, "Identifiant invalide.")

    if not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(401, "Mot de passe invalide.")

    # Identifiant unique appareil
    device_identifier = request.headers.get("X-Device-ID", str(uuid.uuid4()))
    ua = request.headers.get("User-Agent", "")
    ip = request.client.host if request.client else None

    # 🔐 GESTION ADMIN vs UTILISATEUR NORMAL
    if user.is_admin:
        # ========== ADMIN ==========
        # Vérifier si une session existe déjà pour cet appareil
        existing_session = db.query(models.AdminSession).filter(
            models.AdminSession.admin_id == user.id,
            models.AdminSession.device_id == device_identifier,
            models.AdminSession.active == True,
            models.AdminSession.expires_at > datetime.utcnow()
        ).first()
        
        if existing_session:
            # Réutiliser la session existante en mettant à jour l'expiration
            existing_session.expires_at = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            existing_session.ip = ip
            existing_session.user_agent = ua
            existing_session.active = True
            db.commit()
        else:
            # Vérifier limite de sessions admin pour cet admin (max 3 appareils par admin)
            active_admin_sessions = db.query(func.count(models.AdminSession.id)).filter(
                models.AdminSession.admin_id == user.id,
                models.AdminSession.active == True,
                models.AdminSession.expires_at > datetime.utcnow()
            ).scalar() or 0
            
            if active_admin_sessions >= 3:
                raise HTTPException(
                    status_code=403,
                    detail="Limite de 3 appareils admin atteinte."
                )
            
            # Supprimer les anciennes sessions du même device_id (si elles existent)
            db.query(models.AdminSession).filter(
                models.AdminSession.admin_id == user.id,
                models.AdminSession.device_id == device_identifier
            ).delete()
            
            # Créer nouvelle session admin
            expires_at = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            admin_session = models.AdminSession(
                admin_id=user.id,
                device_id=device_identifier,
                ip=ip,
                user_agent=ua,
                expires_at=expires_at,
                active=True
            )
            db.add(admin_session)
            db.commit()
        
        # Pour les admins, on ne vérifie PAS la limite des appareils
        # Ils peuvent se connecter depuis n'importe quel device
        get_or_create_device(db, user.id, device_identifier, ip, ua)
    else:
        # ========== UTILISATEUR NORMAL ==========
        # Vérifier si une session existe déjà pour cet appareil
        existing_session = db.query(models.UserSession).filter(
            models.UserSession.user_id == user.id,
            models.UserSession.device_id == device_identifier,
            models.UserSession.active == True,
            models.UserSession.expires_at > datetime.utcnow()
        ).first()
        
        if existing_session:
            # Réutiliser la session existante en mettant à jour l'expiration
            existing_session.expires_at = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            existing_session.ip = ip
            existing_session.user_agent = ua
            existing_session.active = True
            db.commit()
        else:
            # Vérifier si l'utilisateur a déjà une session active (1 seul appareil max)
            active_sessions = db.query(func.count(models.UserSession.id)).filter(
                models.UserSession.user_id == user.id,
                models.UserSession.active == True,
                models.UserSession.expires_at > datetime.utcnow()
            ).scalar() or 0
            
            if active_sessions >= 1:
                raise HTTPException(
                    status_code=403,
                    detail="Ce compte utilise déjà un appareil."
                )
            
            # Supprimer les anciennes sessions du même device_id (si elles existent)
            db.query(models.UserSession).filter(
                models.UserSession.user_id == user.id,
                models.UserSession.device_id == device_identifier
            ).delete()
            
            # Créer nouvelle session utilisateur
            expires_at = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
            user_session = models.UserSession(
                user_id=user.id,
                device_id=device_identifier,
                ip=ip,
                user_agent=ua,
                expires_at=expires_at,
                active=True
            )
            db.add(user_session)
            db.commit()

        # Obtenir ou créer device
        get_or_create_device(db, user.id, device_identifier, ip, ua)

    # Mettre à jour dernière connexion
    user.last_login_at = datetime.utcnow()
    user.last_login_ip = ip
    db.commit()
    db.refresh(user)

    # Tokens avec is_admin et role
    payload = {
        "sub": user.phone_number,
        "uid": user.id,
        "is_admin": user.is_admin,
        "role": "admin" if user.is_admin else "user"
    }
    if user.is_admin and user.admin_role:
        payload["admin_role"] = user.admin_role
    
    access = create_access_token(payload)
    refresh = create_refresh_token(payload)

    return schemas.LoginResponse(
        access_token=access,
        refresh_token=refresh,
        token_type="bearer",
        user=schemas.UserOut.from_orm(user)
    )


# ======================================================
# REFRESH TOKEN
# ======================================================
@router.post("/refresh", response_model=schemas.Token)
def refresh_token_endpoint(
    credentials: HTTPAuthorizationCredentials = Depends(HTTPBearer())
):
    token = credentials.credentials
    payload = decode_token(token)

    if payload.get("type") != "refresh":
        raise HTTPException(401, "Refresh token invalide.")

    new_access = create_access_token({"sub": payload["sub"], "uid": payload["uid"]})
    new_refresh = create_refresh_token({"sub": payload["sub"], "uid": payload["uid"]})

    return {
        "access_token": new_access,
        "refresh_token": new_refresh,
        "token_type": "bearer",
    }


# ======================================================
# FORGOT PASSWORD
# ======================================================
@router.post("/forgot-password")
def forgot_password(data: schemas.ForgotPassword, db: Session = Depends(get_db)):
    user = get_user_by_phone(db, data.phone)
    if not user:
        raise HTTPException(404, "Numéro introuvable.")

    reset_code = generate_otp()
    user.reset_code = reset_code
    db.commit()

    return {"message": "Code envoyé", "code": reset_code}


# ======================================================
# RESET PASSWORD (compatible Flutter - phone optionnel)
# ======================================================
@router.post("/reset-password")
def reset_password(data: schemas.ResetPassword, db: Session = Depends(get_db)):
    """
    Réinitialiser le mot de passe.
    Si phone n'est pas fourni, chercher l'utilisateur via le code.
    """
    user = None
    
    if data.phone:
        user = get_user_by_phone(db, data.phone)
    else:
        # Chercher par code de reset
        user = db.query(models.User).filter(models.User.reset_code == data.code).first()

    if not user:
        raise HTTPException(404, "Utilisateur introuvable.")

    if user.reset_code != data.code:
        raise HTTPException(400, "Code invalide.")

    user.hashed_password = hash_password(data.new_password)
    user.reset_code = None
    db.commit()

    return {"message": "Mot de passe réinitialisé."}


# ======================================================
# OAUTH LOGIN (pour Swagger/tests)
# ======================================================
@router.post("/oauth-login", response_model=schemas.Token)
def oauth_login(form_data: OAuth2PasswordRequestForm = Depends(),
                db: Session = Depends(get_db)):

    user = get_user_by_phone(db, form_data.username)
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(401, "Identifiants invalides.")

    payload = {"sub": user.phone_number, "uid": user.id}
    access = create_access_token(payload)
    refresh = create_refresh_token(payload)

    return {
        "access_token": access,
        "refresh_token": refresh,
        "token_type": "bearer",
    }


# ======================================================
# CURRENT USER
# ======================================================
@router.get("/me", response_model=schemas.UserOut)
def get_profile(user: models.User = Depends(secure_get_current_user)):
    return user
