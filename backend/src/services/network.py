import os
from datetime import timedelta, datetime

from src.services.network.providers import MockNetwork, MikroTikNetwork, UniFiNetwork, RadiusNetwork

class NetworkService:
    def __init__(self):
        mode = os.getenv("NETWORK_MODE", "mock").lower()
        if mode == "mikrotik":
            self.provider = MikroTikNetwork()
        elif mode == "unifi":
            self.provider = UniFiNetwork()
        elif mode == "radius":
            self.provider = RadiusNetwork()
        else:
            self.provider = MockNetwork()

    def activate_access(self, user_id: str, duration_hours: int, device_mac: str | None = None):
        until = datetime.utcnow() + timedelta(hours=duration_hours)
        return self.provider.grant(user_id=user_id, until=until, device_mac=device_mac)

    def deactivate_access(self, user_id: str, device_mac: str | None = None):
        return self.provider.revoke(user_id=user_id, device_mac=device_mac)
