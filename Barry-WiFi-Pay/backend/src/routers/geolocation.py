# backend/src/routers/geolocation.py
"""
🌍 Géolocalisation LÉGALE pour BARRY WiFi
Conforme RGPD - Opt-in utilisateur obligatoire
Gestion des zones d'accès WiFi (pas Internet global)
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel
import math

from ..db import get_db
from ..security import get_current_user
from ..deps import admin_required as admin_required_dep
from ..models import User, UserGeolocation, BlockedZone, Device
from ..middleware.admin_logs import admin_logger, LogCategory, LogLevel

router = APIRouter(prefix="/geo", tags=["Geolocation"])


# ============================================================
# SCHEMAS
# ============================================================
class LocationUpdate(BaseModel):
    latitude: float
    longitude: float
    accuracy: Optional[float] = None
    device_id: Optional[str] = None


class ZoneCreateRequest(BaseModel):
    name: str
    description: Optional[str] = None
    zone_type: str = "allow"  # allow, deny
    scope: str = "wifi_network"  # wifi_network, city, region, country
    
    # Pour zones géographiques
    center_latitude: Optional[float] = None
    center_longitude: Optional[float] = None
    radius_km: Optional[float] = None
    
    # Pour zones réseau WiFi
    ssid: Optional[str] = None
    bssid: Optional[str] = None
    
    # Pour zones administratives
    country_code: Optional[str] = None
    region_code: Optional[str] = None
    city_name: Optional[str] = None


# ============================================================
# HELPERS
# ============================================================
# Note: admin_required est maintenant importé depuis deps.py


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calcule la distance en km entre deux points GPS"""
    R = 6371  # Rayon de la Terre en km
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = math.sin(delta_lat/2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(delta_lon/2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    
    return R * c


# ============================================================
# 🔐 ACTIVER/DÉSACTIVER GÉOLOCALISATION (User)
# ============================================================
@router.post("/enable")
def enable_geolocation(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Active la géolocalisation pour l'utilisateur (opt-in RGPD)"""
    user.geo_enabled = True
    db.commit()
    
    return {
        "ok": True,
        "message": "Géolocalisation activée. Vous acceptez que votre position approximative soit collectée pour le service WiFi.",
        "geo_enabled": True
    }


@router.post("/disable")
def disable_geolocation(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Désactive la géolocalisation et supprime l'historique"""
    user.geo_enabled = False
    user.last_latitude = None
    user.last_longitude = None
    user.last_geo_update = None
    
    # Supprimer l'historique (droit à l'oubli RGPD)
    db.query(UserGeolocation).filter(UserGeolocation.user_id == user.id).delete()
    
    db.commit()
    
    return {
        "ok": True,
        "message": "Géolocalisation désactivée. Vos données de position ont été supprimées.",
        "geo_enabled": False
    }


# ============================================================
# 📍 METTRE À JOUR LA POSITION (User)
# ============================================================
@router.post("/update")
def update_location(
    data: LocationUpdate,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Met à jour la position de l'utilisateur"""
    
    # Vérifier que la géolocalisation est activée
    if not user.geo_enabled:
        raise HTTPException(403, "Géolocalisation non activée. Activez-la d'abord.")
    
    # Validation des coordonnées
    if not (-90 <= data.latitude <= 90) or not (-180 <= data.longitude <= 180):
        raise HTTPException(400, "Coordonnées GPS invalides")
    
    now = datetime.utcnow()
    
    # Mettre à jour l'utilisateur
    user.last_latitude = data.latitude
    user.last_longitude = data.longitude
    user.last_geo_update = now
    
    # Enregistrer dans l'historique
    geo_record = UserGeolocation(
        user_id=user.id,
        latitude=data.latitude,
        longitude=data.longitude,
        accuracy=data.accuracy,
        recorded_at=now
    )
    db.add(geo_record)
    
    # Vérifier si dans une zone autorisée/bloquée
    zone_status = check_zone_access(db, data.latitude, data.longitude)
    
    db.commit()
    
    return {
        "ok": True,
        "position_updated": True,
        "zone_status": zone_status
    }


def check_zone_access(db: Session, lat: float, lon: float) -> dict:
    """Vérifie si une position est dans une zone autorisée/bloquée"""
    
    zones = db.query(BlockedZone).filter(BlockedZone.is_active == True).all()
    
    in_allowed_zone = False
    in_denied_zone = False
    zone_info = None
    
    for zone in zones:
        if zone.center_latitude and zone.center_longitude and zone.radius_km:
            distance = haversine_distance(lat, lon, zone.center_latitude, zone.center_longitude)
            
            if distance <= zone.radius_km:
                if zone.zone_type == "allow":
                    in_allowed_zone = True
                    zone_info = {"name": zone.name, "type": "allowed"}
                elif zone.zone_type == "deny":
                    in_denied_zone = True
                    zone_info = {"name": zone.name, "type": "denied"}
    
    return {
        "allowed": in_allowed_zone and not in_denied_zone,
        "in_allowed_zone": in_allowed_zone,
        "in_denied_zone": in_denied_zone,
        "zone": zone_info
    }


# ============================================================
# 📊 STATUT GÉOLOCALISATION (User)
# ============================================================
@router.get("/status")
def get_geo_status(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Retourne le statut de géolocalisation de l'utilisateur"""
    return {
        "enabled": user.geo_enabled,
        "last_position": {
            "latitude": user.last_latitude,
            "longitude": user.last_longitude,
            "updated_at": str(user.last_geo_update) if user.last_geo_update else None
        } if user.geo_enabled and user.last_latitude else None
    }


# ============================================================
# 🗺️ ADMIN: LISTE DES ZONES
# ============================================================
@router.get("/admin/zones")
def list_zones(
    active_only: bool = True,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Liste toutes les zones configurées"""
    
    query = db.query(BlockedZone)
    if active_only:
        query = query.filter(BlockedZone.is_active == True)
    
    zones = query.order_by(BlockedZone.created_at.desc()).all()
    
    return {
        "count": len(zones),
        "zones": [
            {
                "id": z.id,
                "name": z.name,
                "description": z.description,
                "zone_type": z.zone_type,
                "scope": z.scope,
                "center_latitude": z.center_latitude,
                "center_longitude": z.center_longitude,
                "radius_km": z.radius_km,
                "ssid": z.ssid,
                "country_code": z.country_code,
                "region_code": z.region_code,
                "city_name": z.city_name,
                "is_active": z.is_active,
                "created_at": str(z.created_at)
            }
            for z in zones
        ]
    }


# ============================================================
# ➕ ADMIN: CRÉER UNE ZONE
# ============================================================
@router.post("/admin/zones")
def create_zone(
    data: ZoneCreateRequest,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """
    Crée une nouvelle zone d'accès WiFi.
    
    ⚠️ IMPORTANT: Ceci contrôle l'accès à VOTRE réseau WiFi uniquement,
    pas à Internet en général. Conforme aux lois locales.
    """
    
    # Validation
    if data.zone_type not in ["allow", "deny"]:
        raise HTTPException(400, "zone_type doit être 'allow' ou 'deny'")
    
    valid_scopes = ["wifi_network", "city", "region", "country"]
    if data.scope not in valid_scopes:
        raise HTTPException(400, f"scope invalide. Choix: {valid_scopes}")
    
    # Pour une zone géographique, les coordonnées sont obligatoires
    if data.scope in ["city", "region"] and not (data.center_latitude and data.center_longitude):
        raise HTTPException(400, "Coordonnées requises pour ce type de zone")
    
    zone = BlockedZone(
        name=data.name,
        description=data.description,
        zone_type=data.zone_type,
        scope=data.scope,
        center_latitude=data.center_latitude,
        center_longitude=data.center_longitude,
        radius_km=data.radius_km,
        ssid=data.ssid,
        bssid=data.bssid,
        country_code=data.country_code,
        region_code=data.region_code,
        city_name=data.city_name,
        is_active=True,
        created_by=user.id,
        created_at=datetime.utcnow()
    )
    
    db.add(zone)
    db.commit()
    db.refresh(zone)
    
    admin_logger.log_admin_action(
        admin_id=user.id,
        action="zone_created",
        target_type="zone",
        target_id=zone.id,
        description=f"Zone '{data.name}' ({data.zone_type}) créée"
    )
    
    return {
        "ok": True,
        "zone_id": zone.id,
        "message": f"Zone '{data.name}' créée"
    }


# ============================================================
# ✏️ ADMIN: MODIFIER UNE ZONE
# ============================================================
@router.put("/admin/zones/{zone_id}")
def update_zone(
    zone_id: int,
    data: ZoneCreateRequest,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Modifie une zone existante"""
    
    zone = db.query(BlockedZone).filter(BlockedZone.id == zone_id).first()
    if not zone:
        raise HTTPException(404, "Zone non trouvée")
    
    zone.name = data.name
    zone.description = data.description
    zone.zone_type = data.zone_type
    zone.scope = data.scope
    zone.center_latitude = data.center_latitude
    zone.center_longitude = data.center_longitude
    zone.radius_km = data.radius_km
    zone.ssid = data.ssid
    zone.bssid = data.bssid
    zone.country_code = data.country_code
    zone.region_code = data.region_code
    zone.city_name = data.city_name
    zone.updated_at = datetime.utcnow()
    
    db.commit()
    
    return {"ok": True, "message": "Zone modifiée"}


# ============================================================
# 🗑️ ADMIN: SUPPRIMER UNE ZONE
# ============================================================
@router.delete("/admin/zones/{zone_id}")
def delete_zone(
    zone_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Supprime une zone"""
    
    zone = db.query(BlockedZone).filter(BlockedZone.id == zone_id).first()
    if not zone:
        raise HTTPException(404, "Zone non trouvée")
    
    name = zone.name
    db.delete(zone)
    db.commit()
    
    admin_logger.log_admin_action(
        admin_id=user.id,
        action="zone_deleted",
        target_type="zone",
        target_id=zone_id,
        description=f"Zone '{name}' supprimée"
    )
    
    return {"ok": True, "message": "Zone supprimée"}


# ============================================================
# 🔄 ADMIN: ACTIVER/DÉSACTIVER UNE ZONE
# ============================================================
@router.post("/admin/zones/{zone_id}/toggle")
def toggle_zone(
    zone_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Active ou désactive une zone"""
    
    zone = db.query(BlockedZone).filter(BlockedZone.id == zone_id).first()
    if not zone:
        raise HTTPException(404, "Zone non trouvée")
    
    zone.is_active = not zone.is_active
    zone.updated_at = datetime.utcnow()
    db.commit()
    
    status = "activée" if zone.is_active else "désactivée"
    return {"ok": True, "is_active": zone.is_active, "message": f"Zone {status}"}


# ============================================================
# 🗺️ ADMIN: CARTE DES UTILISATEURS
# ============================================================
@router.get("/admin/users-map")
def get_users_map(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Retourne les positions des utilisateurs (anonymisées) pour la carte admin"""
    
    users = db.query(User).filter(
        User.geo_enabled == True,
        User.last_latitude != None
    ).all()
    
    # Anonymiser: arrondir les coordonnées
    points = []
    for u in users:
        points.append({
            "lat": round(u.last_latitude, 2),  # Précision ~1km
            "lng": round(u.last_longitude, 2),
            "active": u.is_active
        })
    
    return {
        "total_with_geo": len(points),
        "points": points
    }


# ============================================================
# 📊 ADMIN: STATS GÉOLOCALISATION
# ============================================================
@router.get("/admin/stats")
def get_geo_stats(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required_dep)
):
    """Statistiques de géolocalisation"""
    
    total_users = db.query(func.count(User.id)).scalar() or 0
    geo_enabled = db.query(func.count(User.id)).filter(User.geo_enabled == True).scalar() or 0
    with_position = db.query(func.count(User.id)).filter(User.last_latitude != None).scalar() or 0
    
    total_zones = db.query(func.count(BlockedZone.id)).scalar() or 0
    active_zones = db.query(func.count(BlockedZone.id)).filter(BlockedZone.is_active == True).scalar() or 0
    
    return {
        "users": {
            "total": total_users,
            "geo_enabled": geo_enabled,
            "geo_enabled_percent": round((geo_enabled / total_users * 100), 1) if total_users > 0 else 0,
            "with_position": with_position
        },
        "zones": {
            "total": total_zones,
            "active": active_zones
        }
    }

