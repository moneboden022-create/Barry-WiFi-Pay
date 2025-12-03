# backend/src/services/starlink.py
"""
Module Starlink PRO :
- retries
- timeouts
- messages propres
- format unifié (ok: bool, msg: str)
"""

import os
import requests
from requests.adapters import HTTPAdapter, Retry

# ==========================
# CONFIG
# ==========================
STARLINK_URL = os.getenv("STARLINK_URL", "http://192.168.100.1:9200").rstrip("/")
TIMEOUT = float(os.getenv("STARLINK_TIMEOUT", "3"))
RETRIES = int(os.getenv("STARLINK_RETRIES", "2"))

# ==========================
# SESSION (retries automatiques)
# ==========================
session = requests.Session()
session.mount(
    "http://",
    HTTPAdapter(
        max_retries=Retry(
            total=RETRIES,
            backoff_factor=0.3,
            status_forcelist=(500, 502, 503, 504)
        )
    )
)


# ==========================
# REQUÊTES SÉCURISÉES
# ==========================
def _safe_get(path: str):
    try:
        return session.get(f"{STARLINK_URL}{path}", timeout=TIMEOUT)
    except Exception:
        return None


def _safe_post(path: str, json_data: dict):
    try:
        return session.post(f"{STARLINK_URL}{path}", json=json_data, timeout=TIMEOUT)
    except Exception:
        return None


# ==========================
# FONCTIONS API
# ==========================
def starlink_is_online() -> bool:
    r = _safe_get("/v1/device/status")
    return r is not None and r.status_code == 200


def starlink_activate() -> (bool, str):
    r = _safe_post("/v1/network/activation", {"command": "enable"})
    if r is None:
        return False, "Starlink unreachable"

    if r.status_code == 200:
        return True, "Starlink activated"

    return False, f"Activation failed: HTTP {r.status_code}"


def starlink_deactivate() -> (bool, str):
    r = _safe_post("/v1/network/activation", {"command": "disable"})
    if r is None:
        return False, "Starlink unreachable"

    if r.status_code == 200:
        return True, "Starlink deactivated"

    return False, f"Deactivation failed: HTTP {r.status_code}"
