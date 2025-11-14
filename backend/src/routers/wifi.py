from fastapi import APIRouter
from pydantic import BaseModel
from src.services.network import NetworkService

router = APIRouter()
net = NetworkService()

class ActivateRequest(BaseModel):
    user_id: str
    duration_hours: int = 720  # 30 jours par défaut
    device_mac: str | None = None  # optionnel (si connu)

@router.post("/activate")
def activate(payload: ActivateRequest):
    ok = net.activate_access(user_id=payload.user_id,
                             duration_hours=payload.duration_hours,
                             device_mac=payload.device_mac)
    return {"activated": ok}

@router.post("/deactivate")
def deactivate(payload: ActivateRequest):
    ok = net.deactivate_access(user_id=payload.user_id,
                               device_mac=payload.device_mac)
    return {"deactivated": ok}
