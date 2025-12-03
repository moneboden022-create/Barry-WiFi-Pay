# backend/src/services/network/providers.py

"""
Système PRO multi-routeur pour BARRY WIFI.
Chaque provider expose :
    activate_wifi(user_id) -> (bool, msg)
    deactivate_wifi(user_id) -> (bool, msg)
    get_status(user_id) -> (bool, msg)
"""

import os
from typing import Tuple
from abc import ABC, abstractmethod

from ...db import SessionLocal
from ...models import User

# Import Starlink interne corrigé
from ...services.starlink import (
    starlink_is_online,
    starlink_activate,
    starlink_deactivate
)

# =========================================================
# BASE PROVIDER
# =========================================================
class BaseRouterManager(ABC):

    @abstractmethod
    def activate_wifi(self, user_id: int) -> Tuple[bool, str]:
        ...

    @abstractmethod
    def deactivate_wifi(self, user_id: int) -> Tuple[bool, str]:
        ...

    @abstractmethod
    def get_status(self, user_id: int) -> Tuple[bool, str]:
        ...


# =========================================================
# STARLINK (ROUTEUR RÉEL)
# =========================================================
class StarlinkManager(BaseRouterManager):

    def activate_wifi(self, user_id: int) -> Tuple[bool, str]:
        ok = starlink_activate()
        return (ok, "Starlink activated" if ok else "Starlink activation failed")

    def deactivate_wifi(self, user_id: int) -> Tuple[bool, str]:
        ok = starlink_deactivate()
        return (ok, "Starlink deactivated" if ok else "Starlink deactivation failed")

    def get_status(self, user_id: int) -> Tuple[bool, str]:
        ok = starlink_is_online()
        return (ok, "online" if ok else "offline")


# =========================================================
# MIKROTIK (placeholder)
# =========================================================
class MikrotikManager(BaseRouterManager):
    def activate_wifi(self, user_id: int) -> Tuple[bool, str]:
        return True, "Mikrotik stub: activate"

    def deactivate_wifi(self, user_id: int) -> Tuple[bool, str]:
        return True, "Mikrotik stub: deactivate"

    def get_status(self, user_id: int) -> Tuple[bool, str]:
        return True, "Mikrotik stub: status"


# =========================================================
# TP-LINK OMADA (placeholder)
# =========================================================
class TPLinkManager(BaseRouterManager):
    def activate_wifi(self, user_id: int) -> Tuple[bool, str]:
        return True, "TP-Link stub: activate"

    def deactivate_wifi(self, user_id: int) -> Tuple[bool, str]:
        return True, "TP-Link stub: deactivate"

    def get_status(self, user_id: int) -> Tuple[bool, str]:
        return True, "TP-Link stub: status"


# =========================================================
# SSH ROUTER (placeholder)
# =========================================================
class SSHRouterManager(BaseRouterManager):
    def __init__(self):
        self.host = os.getenv("ROUTER_SSH_HOST")
        self.user = os.getenv("ROUTER_SSH_USER")
        self.password = os.getenv("ROUTER_SSH_PASSWORD")

    def activate_wifi(self, user_id: int) -> Tuple[bool, str]:
        return True, "SSH stub: activate"

    def deactivate_wifi(self, user_id: int) -> Tuple[bool, str]:
        return True, "SSH stub: deactivate"

    def get_status(self, user_id: int) -> Tuple[bool, str]:
        return True, "SSH stub: status"


# =========================================================
# FACADE : WifiNetworkManager
# =========================================================
class WifiNetworkManager:

    def __init__(self):
        provider = os.getenv("ROUTER_PROVIDER", "starlink").lower()

        self.impl = {
            "starlink": StarlinkManager(),
            "mikrotik": MikrotikManager(),
            "tplink": TPLinkManager(),
            "omada": TPLinkManager(),
            "ssh": SSHRouterManager(),
            "generic": SSHRouterManager(),
        }.get(provider, StarlinkManager())

    # ---------------------------- ACTIVATION ----------------------------
    def activate_wifi(self, user_id: int) -> Tuple[bool, str]:
        # Vérifier que l'utilisateur existe
        try:
            with SessionLocal() as db:
                if not db.query(User).filter(User.id == user_id).first():
                    return False, "User not found"
        except:
            pass

        try:
            return self.impl.activate_wifi(user_id)
        except Exception as e:
            return False, f"Provider error: {e}"

    # ---------------------------- DESACTIVATION ----------------------------
    def deactivate_wifi(self, user_id: int) -> Tuple[bool, str]:
        try:
            return self.impl.deactivate_wifi(user_id)
        except Exception as e:
            return False, f"Provider error: {e}"

    # ---------------------------- STATUS ----------------------------
    def get_status(self, user_id: int) -> Tuple[bool, str]:
        try:
            return self.impl.get_status(user_id)
        except Exception as e:
            return False, f"Provider error: {e}"
