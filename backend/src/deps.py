# backend/src/deps.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from .db import get_db
from .models import User
from .security import get_current_user as secure_get_current_user

reusable_oauth2 = HTTPBearer()

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(reusable_oauth2),
    db: Session = Depends(get_db),
) -> User:
    """Dépendance pour obtenir l'utilisateur actuel depuis le token JWT."""
    return secure_get_current_user(credentials, db)


def admin_required(user: User = Depends(secure_get_current_user)) -> User:
    """
    Dépendance pour vérifier que l'utilisateur est administrateur.
    À utiliser sur toutes les routes admin.
    """
    if not user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Accès interdit. Réservé aux administrateurs."
        )
    return user
