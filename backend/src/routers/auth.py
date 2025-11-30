from fastapi import (
    APIRouter, Depends, HTTPException, status,
    Request, UploadFile, File, Form
)
from fastapi.security import OAuth2PasswordRequestForm, HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional
import uuid
import shutil
from pathlib import Path

from ..db import get_db
from .. import models, schemas
from ..security import (
    verify_password,
    hash_password,
    create_access_token,
    create_refresh_token,
    decode_token,
    get_current_user as secure_get_current_user
)
from ..utils import (
    get_user_by_phone,
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
# REGISTER (multipart + avatar)
# ======================================================
@router.post("/register", response_model=schemas.UserOut)
async def register_user(
    first_name: str = Form(...),
    last_name: str = Form(...),
    phone_number: str = Form(...),
    country: str = Form(...),
    password: str = Form(...),
    isBusiness: bool = Form(...),
    avatar: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    # Vérifier numéro existant
    existing = get_user_by_phone(db, phone_number)
    if existing:
        raise HTTPException(status_code=400, detail="Ce numéro est déjà utilisé.")

    # Upload avatar
    avatar_url = None
    if avatar:
        ext = avatar.filename.split('.')[-1]
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

    return user


# ======================================================
# LOGIN (multi-device, jwt)
# ======================================================
@router.post("/login", response_model=schemas.Token)
def login(request: Request, user_in: schemas.UserLogin, db: Session = Depends(get_db)):
    user = get_user_by_phone(db, user_in.phone_number)
    if not user:
        raise HTTPException(401, "Numéro invalide.")

    if not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(401, "Mot de passe invalide.")

    # Identifiant unique appareil
    device_identifier = request.headers.get("X-Device-ID", str(uuid.uuid4()))
    ua = request.headers.get("User-Agent", "")
    ip = request.client.host if request.client else None

    # Vérifier limite appareils
    device_count = count_user_devices(db, user.id)
    if device_count >= user.max_devices_allowed:
        existing = db.query(models.Device).filter(
            models.Device.user_id == user.id,
            models.Device.identifier == device_identifier
        ).first()

        if not existing:
            raise HTTPException(
                403,
                f"Limite d'appareils atteinte ({user.max_devices_allowed})."
            )

    # Obtenir ou créer device
    get_or_create_device(db, user.id, device_identifier, ip, ua)

    # Nettoyage
    cleanup_old_devices(db, user.id, user.max_devices_allowed)

    # Tokens
    payload = {"sub": user.phone_number, "uid": user.id}
    access = create_access_token(payload)
    refresh = create_refresh_token(payload)

    return {
        "access_token": access,
        "refresh_token": refresh,
        "token_type": "bearer",
    }


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
# RESET PASSWORD
# ======================================================
@router.post("/reset-password")
def reset_password(data: schemas.ResetPassword, db: Session = Depends(get_db)):
    user = get_user_by_phone(db, data.phone)
    if not user:
        raise HTTPException(404, "Numéro introuvable.")

    if user.reset_code != data.code:
        raise HTTPException(400, "Code invalide.")

    user.hashed_password = hash_password(data.new_password)
    user.reset_code = None
    db.commit()

    return {"message": "Mot de passe réinitialisé."}


# ======================================================
# OAUTH LOGIN
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
