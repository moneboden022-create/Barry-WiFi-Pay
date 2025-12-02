# backend/src/routers/admin_vouchers.py
"""
🎟️ Gestion avancée des Vouchers Admin pour BARRY WiFi
CRUD complet, multi-devices, QR, batch création
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel
import uuid
import qrcode
import base64
from io import BytesIO

from ..db import get_db
from ..security import get_current_user
from ..models import User, Voucher, Subscription
from ..middleware.admin_logs import admin_logger, LogCategory

router = APIRouter(prefix="/admin/vouchers", tags=["Admin Vouchers"])


# ============================================================
# SCHEMAS
# ============================================================
class VoucherCreateRequest(BaseModel):
    type: str = "individual"  # individual, business, enterprise, vip
    duration_minutes: int = 60
    max_devices: int = 1
    quantity: int = 1
    prefix: Optional[str] = None  # Préfixe personnalisé


class VoucherUpdateRequest(BaseModel):
    type: Optional[str] = None
    duration_minutes: Optional[int] = None
    max_devices: Optional[int] = None
    is_used: Optional[bool] = None


class VoucherBatchResponse(BaseModel):
    created: int
    vouchers: List[dict]


# ============================================================
# HELPERS
# ============================================================
def admin_required(user: User):
    if not getattr(user, "is_admin", False):
        raise HTTPException(status_code=403, detail="Accès réservé aux administrateurs")


def generate_voucher_code(prefix: str = None) -> str:
    """Génère un code voucher unique"""
    code = str(uuid.uuid4())[:8].upper()
    if prefix:
        return f"{prefix}-{code}"
    return f"BWIFI-{code}"


def generate_qr_base64(data: str) -> str:
    """Génère un QR code en base64"""
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data)
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    img.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode()


# ============================================================
# 📋 LISTE DES VOUCHERS
# ============================================================
@router.get("/")
def list_vouchers(
    status: Optional[str] = Query(None, description="used, available, all"),
    type: Optional[str] = Query(None, description="individual, business, enterprise"),
    limit: int = 100,
    offset: int = 0,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Liste tous les vouchers avec filtres"""
    admin_required(user)
    
    query = db.query(Voucher)
    
    if status == "used":
        query = query.filter(Voucher.is_used == True)
    elif status == "available":
        query = query.filter(Voucher.is_used == False)
    
    if type:
        query = query.filter(Voucher.type == type)
    
    total = query.count()
    vouchers = query.order_by(Voucher.created_at.desc()).limit(limit).offset(offset).all()
    
    return {
        "total": total,
        "count": len(vouchers),
        "vouchers": [
            {
                "id": v.id,
                "code": v.code,
                "type": v.type,
                "duration_minutes": v.duration_minutes,
                "max_devices": v.max_devices,
                "is_used": v.is_used,
                "used_by": v.used_by,
                "used_at": str(v.used_at) if v.used_at else None,
                "created_at": str(v.created_at),
                "qr_data": v.qr_data
            }
            for v in vouchers
        ]
    }


# ============================================================
# ➕ CRÉER UN VOUCHER
# ============================================================
@router.post("/create")
def create_voucher(
    data: VoucherCreateRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Crée un ou plusieurs vouchers"""
    admin_required(user)
    
    # Validation
    if data.quantity < 1 or data.quantity > 100:
        raise HTTPException(400, "Quantité entre 1 et 100")
    
    if data.duration_minutes < 1:
        raise HTTPException(400, "Durée minimum: 1 minute")
    
    valid_types = ["individual", "business", "enterprise", "vip"]
    if data.type not in valid_types:
        raise HTTPException(400, f"Type invalide. Choix: {valid_types}")
    
    # Ajuster max_devices selon le type
    if data.type == "individual" and data.max_devices > 1:
        data.max_devices = 1
    elif data.type == "business" and data.max_devices < 3:
        data.max_devices = 3
    elif data.type == "enterprise" and data.max_devices < 10:
        data.max_devices = 10
    
    created_vouchers = []
    
    for _ in range(data.quantity):
        code = generate_voucher_code(data.prefix)
        
        # Vérifier unicité
        while db.query(Voucher).filter(Voucher.code == code).first():
            code = generate_voucher_code(data.prefix)
        
        qr_data = generate_qr_base64(code)
        
        voucher = Voucher(
            code=code,
            type=data.type,
            duration_minutes=data.duration_minutes,
            max_devices=data.max_devices,
            qr_data=qr_data,
            created_at=datetime.utcnow()
        )
        
        db.add(voucher)
        created_vouchers.append({
            "code": code,
            "type": data.type,
            "duration_minutes": data.duration_minutes,
            "max_devices": data.max_devices
        })
    
    db.commit()
    
    # Logger
    admin_logger.log_voucher_action(
        action="vouchers_created",
        admin_id=user.id,
        description=f"Création de {data.quantity} voucher(s) de type {data.type}"
    )
    
    return {
        "ok": True,
        "created": len(created_vouchers),
        "vouchers": created_vouchers
    }


# ============================================================
# 📖 DÉTAIL D'UN VOUCHER
# ============================================================
@router.get("/{voucher_id}")
def get_voucher_detail(
    voucher_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Détails complets d'un voucher"""
    admin_required(user)
    
    voucher = db.query(Voucher).filter(Voucher.id == voucher_id).first()
    if not voucher:
        raise HTTPException(404, "Voucher non trouvé")
    
    # Infos utilisateur si utilisé
    used_by_user = None
    if voucher.used_by:
        u = db.query(User).filter(User.id == voucher.used_by).first()
        if u:
            used_by_user = {
                "id": u.id,
                "name": f"{u.first_name} {u.last_name}",
                "phone": u.phone_number
            }
    
    # Sessions actives (pour business/enterprise)
    active_sessions = 0
    if voucher.type in ["business", "enterprise"]:
        active_sessions = db.query(Subscription).filter(
            Subscription.voucher_code == voucher.code,
            Subscription.is_active == True,
            Subscription.end_at > datetime.utcnow()
        ).count()
    
    return {
        "id": voucher.id,
        "code": voucher.code,
        "type": voucher.type,
        "duration_minutes": voucher.duration_minutes,
        "max_devices": voucher.max_devices,
        "is_used": voucher.is_used,
        "used_by": used_by_user,
        "used_at": str(voucher.used_at) if voucher.used_at else None,
        "active_sessions": active_sessions,
        "remaining_devices": voucher.max_devices - active_sessions,
        "created_at": str(voucher.created_at),
        "qr_data": voucher.qr_data
    }


# ============================================================
# ✏️ MODIFIER UN VOUCHER
# ============================================================
@router.put("/{voucher_id}")
def update_voucher(
    voucher_id: int,
    data: VoucherUpdateRequest,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Modifie un voucher existant"""
    admin_required(user)
    
    voucher = db.query(Voucher).filter(Voucher.id == voucher_id).first()
    if not voucher:
        raise HTTPException(404, "Voucher non trouvé")
    
    if data.type:
        voucher.type = data.type
    if data.duration_minutes:
        voucher.duration_minutes = data.duration_minutes
    if data.max_devices:
        voucher.max_devices = data.max_devices
    if data.is_used is not None:
        voucher.is_used = data.is_used
        if not data.is_used:
            voucher.used_by = None
            voucher.used_at = None
    
    db.commit()
    
    admin_logger.log_voucher_action(
        action="voucher_updated",
        voucher_code=voucher.code,
        admin_id=user.id,
        description=f"Voucher {voucher.code} modifié"
    )
    
    return {"ok": True, "message": "Voucher modifié"}


# ============================================================
# 🗑️ SUPPRIMER UN VOUCHER
# ============================================================
@router.delete("/{voucher_id}")
def delete_voucher(
    voucher_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Supprime un voucher (si non utilisé)"""
    admin_required(user)
    
    voucher = db.query(Voucher).filter(Voucher.id == voucher_id).first()
    if not voucher:
        raise HTTPException(404, "Voucher non trouvé")
    
    if voucher.is_used:
        raise HTTPException(400, "Impossible de supprimer un voucher déjà utilisé")
    
    code = voucher.code
    db.delete(voucher)
    db.commit()
    
    admin_logger.log_voucher_action(
        action="voucher_deleted",
        voucher_code=code,
        admin_id=user.id,
        description=f"Voucher {code} supprimé"
    )
    
    return {"ok": True, "message": "Voucher supprimé"}


# ============================================================
# 🚫 DÉSACTIVER UN VOUCHER
# ============================================================
@router.post("/{voucher_id}/disable")
def disable_voucher(
    voucher_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Désactive un voucher (le marque comme utilisé)"""
    admin_required(user)
    
    voucher = db.query(Voucher).filter(Voucher.id == voucher_id).first()
    if not voucher:
        raise HTTPException(404, "Voucher non trouvé")
    
    voucher.is_used = True
    voucher.used_at = datetime.utcnow()
    db.commit()
    
    admin_logger.log_voucher_action(
        action="voucher_disabled",
        voucher_code=voucher.code,
        admin_id=user.id,
        description=f"Voucher {voucher.code} désactivé manuellement"
    )
    
    return {"ok": True, "message": "Voucher désactivé"}


# ============================================================
# ✅ RÉACTIVER UN VOUCHER
# ============================================================
@router.post("/{voucher_id}/enable")
def enable_voucher(
    voucher_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Réactive un voucher (le marque comme non utilisé)"""
    admin_required(user)
    
    voucher = db.query(Voucher).filter(Voucher.id == voucher_id).first()
    if not voucher:
        raise HTTPException(404, "Voucher non trouvé")
    
    voucher.is_used = False
    voucher.used_by = None
    voucher.used_at = None
    db.commit()
    
    admin_logger.log_voucher_action(
        action="voucher_enabled",
        voucher_code=voucher.code,
        admin_id=user.id,
        description=f"Voucher {voucher.code} réactivé"
    )
    
    return {"ok": True, "message": "Voucher réactivé"}


# ============================================================
# 📊 STATISTIQUES VOUCHERS
# ============================================================
@router.get("/stats/summary")
def get_voucher_stats(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Statistiques des vouchers"""
    admin_required(user)
    
    total = db.query(func.count(Voucher.id)).scalar() or 0
    used = db.query(func.count(Voucher.id)).filter(Voucher.is_used == True).scalar() or 0
    available = total - used
    
    by_type = db.query(
        Voucher.type,
        func.count(Voucher.id)
    ).group_by(Voucher.type).all()
    
    return {
        "total": total,
        "used": used,
        "available": available,
        "usage_rate": round((used / total * 100), 1) if total > 0 else 0,
        "by_type": {t[0]: t[1] for t in by_type}
    }


# ============================================================
# 🔍 RECHERCHER UN VOUCHER PAR CODE
# ============================================================
@router.get("/search/{code}")
def search_voucher(
    code: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Recherche un voucher par son code"""
    admin_required(user)
    
    voucher = db.query(Voucher).filter(Voucher.code == code.upper()).first()
    if not voucher:
        raise HTTPException(404, "Voucher non trouvé")
    
    return {
        "id": voucher.id,
        "code": voucher.code,
        "type": voucher.type,
        "duration_minutes": voucher.duration_minutes,
        "max_devices": voucher.max_devices,
        "is_used": voucher.is_used,
        "created_at": str(voucher.created_at)
    }

