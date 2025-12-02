# backend/src/routers/admin_auth.py
"""
🔐 Authentification Admin pour BARRY WiFi
Login admin séparé avec code master et JWT role=admin
"""

from fastapi import APIRouter, HTTPException, Depends, Request, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

from ..db import get_db
from ..models import User
from ..security import (
    verify_password,
    create_access_token,
    create_refresh_token,
    get_current_user
)
from ..middleware.rate_limiter import rate_limiter
from ..middleware.admin_logs import admin_logger, LogCategory, LogLevel

router = APIRouter(prefix="/admin/auth", tags=["Admin Authentication"])

# ============================================================
# 🔑 CODE ADMIN MASTER (Founder/PDG)
# ============================================================
ADMIN_MASTER_PASSWORD = "BWIFI-ADMIN-2025"


# ============================================================
# SCHEMAS
# ============================================================
class AdminLoginRequest(BaseModel):
    phone_number: str
    password: str
    admin_code: str  # Code admin obligatoire


class AdminLoginResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    is_admin: bool = True
    admin_role: Optional[str] = None
    user_id: int
    user_name: str


class CreateAdminRequest(BaseModel):
    user_id: int
    admin_code: str
    role: str = "admin"  # admin, moderator, super_admin


# ============================================================
# 🔐 LOGIN ADMIN
# ============================================================
@router.post("/login", response_model=AdminLoginResponse)
async def admin_login(
    request: Request,
    data: AdminLoginRequest,
    db: Session = Depends(get_db)
):
    """
    Connexion admin avec double authentification :
    1. Identifiants utilisateur (phone + password)
    2. Code admin master (BWIFI-ADMIN-2025)
    """
    ip = request.client.host if request.client else "unknown"
    
    # 1. Vérifier le code admin master
    if data.admin_code != ADMIN_MASTER_PASSWORD:
        rate_limiter.record_failed_login(request, "/admin/auth/login")
        admin_logger.log_security_event(
            action="admin_login_invalid_code",
            level=LogLevel.WARNING,
            ip=ip,
            description=f"Tentative avec code admin invalide: {data.phone_number[:4]}***"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Code administrateur invalide"
        )
    
    # 2. Vérifier l'utilisateur
    user = db.query(User).filter(User.phone_number == data.phone_number).first()
    if not user:
        rate_limiter.record_failed_login(request, "/admin/auth/login")
        admin_logger.log_auth_failed(data.phone_number, ip, "user_not_found")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Identifiants invalides"
        )
    
    # 3. Vérifier le mot de passe
    if not verify_password(data.password, user.hashed_password):
        rate_limiter.record_failed_login(request, "/admin/auth/login")
        admin_logger.log_auth_failed(data.phone_number, ip, "invalid_password")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Mot de passe invalide"
        )
    
    # 4. Vérifier les droits admin
    if not user.is_admin:
        admin_logger.log_security_event(
            action="admin_login_not_admin",
            level=LogLevel.WARNING,
            ip=ip,
            description=f"Utilisateur non-admin tente accès: {user.id}"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Ce compte n'a pas les droits administrateur. Contactez le fondateur."
        )
    
    # 5. Vérifier si le compte est actif
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Compte désactivé"
        )
    
    # 6. Vérifier si le compte est verrouillé
    if user.locked_until and user.locked_until > datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Compte temporairement verrouillé"
        )
    
    # 7. Créer les tokens avec role=admin
    payload = {
        "sub": user.phone_number,
        "uid": user.id,
        "role": "admin",
        "admin_role": user.admin_role or "admin"
    }
    
    access_token = create_access_token(payload)
    refresh_token = create_refresh_token(payload)
    
    # 8. Mettre à jour les infos de connexion
    user.last_login_at = datetime.utcnow()
    user.last_login_ip = ip
    user.failed_login_attempts = 0
    db.commit()
    
    # 9. Logger la connexion réussie
    rate_limiter.record_successful_login(request)
    admin_logger.log(
        action="admin_login_success",
        category=LogCategory.AUTH,
        level=LogLevel.INFO,
        admin_id=user.id,
        ip_address=ip,
        description=f"Connexion admin réussie: {user.first_name} {user.last_name}"
    )
    
    return AdminLoginResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        is_admin=True,
        admin_role=user.admin_role or "admin",
        user_id=user.id,
        user_name=f"{user.first_name} {user.last_name}"
    )


# ============================================================
# 👑 CRÉER UN ADMIN (Super Admin uniquement)
# ============================================================
@router.post("/create-admin")
async def create_admin(
    request: Request,
    data: CreateAdminRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Promeut un utilisateur en administrateur.
    Nécessite :
    - Être connecté en tant que super_admin
    - Fournir le code admin master
    """
    ip = request.client.host if request.client else "unknown"
    
    # Vérifier que l'utilisateur actuel est super_admin
    if not current_user.is_admin or current_user.admin_role != "super_admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Seul un super administrateur peut créer des admins"
        )
    
    # Vérifier le code admin
    if data.admin_code != ADMIN_MASTER_PASSWORD:
        admin_logger.log_security_event(
            action="create_admin_invalid_code",
            level=LogLevel.WARNING,
            ip=ip,
            description=f"Tentative création admin avec code invalide par user {current_user.id}"
        )
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Code administrateur invalide"
        )
    
    # Trouver l'utilisateur cible
    target_user = db.query(User).filter(User.id == data.user_id).first()
    if not target_user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    # Valider le rôle
    valid_roles = ["admin", "moderator", "super_admin"]
    if data.role not in valid_roles:
        raise HTTPException(status_code=400, detail=f"Rôle invalide. Choisir parmi: {valid_roles}")
    
    # Promouvoir l'utilisateur
    target_user.is_admin = True
    target_user.admin_role = data.role
    db.commit()
    
    # Logger l'action
    admin_logger.log_admin_action(
        admin_id=current_user.id,
        action="admin_created",
        target_type="user",
        target_id=target_user.id,
        ip=ip,
        description=f"Utilisateur #{target_user.id} promu {data.role}"
    )
    
    return {
        "ok": True,
        "message": f"Utilisateur promu en {data.role}",
        "user_id": target_user.id,
        "admin_role": data.role
    }


# ============================================================
# 🚫 RÉVOQUER UN ADMIN
# ============================================================
@router.post("/revoke-admin/{user_id}")
async def revoke_admin(
    user_id: int,
    request: Request,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Révoque les droits admin d'un utilisateur"""
    ip = request.client.host if request.client else "unknown"
    
    # Vérifier que l'utilisateur actuel est super_admin
    if not current_user.is_admin or current_user.admin_role != "super_admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Seul un super administrateur peut révoquer les admins"
        )
    
    # Ne pas se révoquer soi-même
    if user_id == current_user.id:
        raise HTTPException(status_code=400, detail="Vous ne pouvez pas vous révoquer vous-même")
    
    target_user = db.query(User).filter(User.id == user_id).first()
    if not target_user:
        raise HTTPException(status_code=404, detail="Utilisateur non trouvé")
    
    # Révoquer
    target_user.is_admin = False
    target_user.admin_role = None
    db.commit()
    
    admin_logger.log_admin_action(
        admin_id=current_user.id,
        action="admin_revoked",
        target_type="user",
        target_id=user_id,
        ip=ip,
        description=f"Droits admin révoqués pour user #{user_id}"
    )
    
    return {"ok": True, "message": "Droits administrateur révoqués"}


# ============================================================
# 📋 LISTE DES ADMINS
# ============================================================
@router.get("/list")
async def list_admins(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Liste tous les administrateurs"""
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Accès refusé")
    
    admins = db.query(User).filter(User.is_admin == True).all()
    
    return {
        "count": len(admins),
        "admins": [
            {
                "id": a.id,
                "name": f"{a.first_name} {a.last_name}",
                "phone": a.phone_number,
                "role": a.admin_role or "admin",
                "last_login": str(a.last_login_at) if a.last_login_at else None,
                "created_at": str(a.created_at)
            }
            for a in admins
        ]
    }


# ============================================================
# ✅ VÉRIFIER SESSION ADMIN
# ============================================================
@router.get("/verify")
async def verify_admin_session(
    current_user: User = Depends(get_current_user)
):
    """Vérifie si la session admin est valide"""
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Non administrateur")
    
    return {
        "valid": True,
        "user_id": current_user.id,
        "admin_role": current_user.admin_role or "admin",
        "name": f"{current_user.first_name} {current_user.last_name}"
    }

