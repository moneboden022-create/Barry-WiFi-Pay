import os
from datetime import timedelta, datetime

from src.services.network.providers import (
    MockNetwork,
    MikroTikNetwork,
    UniFiNetwork,
    RadiusNetwork
)

class NetworkService:
    """
    Système unifié pour gérer l'accès réseau :
    - grant / revoke
    - compatible avec MikroTik, UniFi, Radius ou Mock
    """

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

    # ----------------------------------------------------------
    # 🔥 ACTIVER INTERNET POUR X MINUTES
    # ----------------------------------------------------------
    def activate_access(self, user_id: int, minutes: int, device_mac: str | None = None):
        """
        Active internet jusqu’à expiration.
        Retourne (True/False, message)
        """
        try:
            until = datetime.utcnow() + timedelta(minutes=minutes)
            ok, msg = self.provider.grant(
                user_id=user_id,
                until=until,
                device_mac=device_mac
            )
            return ok, msg
        except Exception as e:
            return False, str(e)

    # ----------------------------------------------------------
    # 🛑 DÉSACTIVER INTERNET
    # ----------------------------------------------------------
    def deactivate_access(self, user_id: int, device_mac: str | None = None):
        """
        Coupe internet immédiatement
        """
        try:
            ok, msg = self.provider.revoke(
                user_id=user_id,
                device_mac=device_mac
            )
            return ok, msg
        except Exception as e:
            return False, str(e)

    # ----------------------------------------------------------
    # 📡 STATUS DU ROUTEUR
    # ----------------------------------------------------------
    def status(self, user_id: int = 0):
        try:
            ok, msg = self.provider.status(user_id=user_id)
            return ok, msg
        except Exception as e:
            return False, str(e)
