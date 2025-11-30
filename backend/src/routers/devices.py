# backend/src/routers/devices.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Device
from ..security import get_current_user

router = APIRouter(prefix="/devices", tags=["Devices"])


# ---------------------------------------------------------------------
# 🔥 1. LISTE DES APPAREILS DE L’UTILISATEUR
# ---------------------------------------------------------------------
@router.get("/me")
def my_devices(db: Session = Depends(get_db), user=Depends(get_current_user)):
    devices = (
        db.query(Device)
        .filter(Device.user_id == user.id)
        .order_by(Device.last_seen.desc())
        .all()
    )

    return [
        {
            "id": d.id,
            "identifier": d.identifier,
            "ip": d.ip,
            "user_agent": d.user_agent,
            "is_blocked": d.is_blocked,
            "last_seen": str(d.last_seen),
        }
        for d in devices
    ]


# ---------------------------------------------------------------------
# 🔥 2. DÉSACTIVER / SUPPRIMER UN APPAREIL SPECIFIQUE
# ---------------------------------------------------------------------
@router.post("/unregister/{identifier}")
def unregister_device(
    identifier: str,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    dev = (
        db.query(Device)
        .filter(Device.user_id == user.id, Device.identifier == identifier)
        .first()
    )

    if not dev:
        raise HTTPException(status_code=404, detail="Device not found")

    db.delete(dev)
    db.commit()

    return {"message": f"Device {identifier} unregistered"}
