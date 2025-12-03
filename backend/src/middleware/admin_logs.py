"""
📝 Système de logs administratifs pour BARRY WiFi
Trace toutes les actions importantes pour la sécurité et l'audit
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from enum import Enum
from sqlalchemy.orm import Session
from ..db import SessionLocal
from ..models import AdminLog  # 🔥 Utiliser le modèle existant
import json
import hashlib


class LogLevel(str, Enum):
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"
    SECURITY = "SECURITY"


class LogCategory(str, Enum):
    AUTH = "AUTH"
    ADMIN = "ADMIN"
    VOUCHER = "VOUCHER"
    WIFI = "WIFI"
    USER = "USER"
    PAYMENT = "PAYMENT"
    SECURITY = "SECURITY"
    SYSTEM = "SYSTEM"


class AdminLogger:
    """Gestionnaire de logs administratifs"""

    def __init__(self):
        self._buffer: List[Dict] = []
        self._buffer_size = 10

    def _hash_ip(self, ip: str) -> str:
        return hashlib.sha256(ip.encode()).hexdigest()

    def log(
        self,
        action: str,
        category: LogCategory = LogCategory.SYSTEM,
        level: LogLevel = LogLevel.INFO,
        description: str = None,
        user_id: int = None,
        admin_id: int = None,
        ip_address: str = None,
        user_agent: str = None,
        request_path: str = None,
        request_method: str = None,
        target_type: str = None,
        target_id: int = None,
        extra_data: dict = None,
        db: Session = None
    ):
        log_entry = AdminLog(
            timestamp=datetime.utcnow(),
            level=level.value if isinstance(level, LogLevel) else level,
            category=category.value if isinstance(category, LogCategory) else category,
            action=action,
            description=description,
            user_id=user_id,
            admin_id=admin_id,
            ip_address=ip_address,
            ip_hash=self._hash_ip(ip_address) if ip_address else None,
            user_agent=user_agent[:500] if user_agent else None,
            request_path=request_path,
            request_method=request_method,
            target_type=target_type,
            target_id=target_id,
            extra_data=json.dumps(extra_data) if extra_data else None
        )

        try:
            if db:
                db.add(log_entry)
                db.commit()
            else:
                with SessionLocal() as session:
                    session.add(log_entry)
                    session.commit()
        except Exception as e:
            print(f"[LOG ERROR] {e}")

    def log_auth_success(self, user_id, ip, user_agent=None):
        self.log(
            action="login_success",
            category=LogCategory.AUTH,
            level=LogLevel.INFO,
            user_id=user_id,
            ip_address=ip,
            user_agent=user_agent,
            description=f"Connexion réussie pour user #{user_id}"
        )

    def log_auth_failed(self, identifier, ip, reason=None):
        self.log(
            action="login_failed",
            category=LogCategory.AUTH,
            level=LogLevel.WARNING,
            ip_address=ip,
            description=f"Échec connexion pour {identifier[:4]}***: {reason}"
        )

    def log_voucher_action(
        self,
        action: str,
        voucher_code: str = None,
        admin_id: int = None,
        description: str = None,
        extra_data: dict = None
    ):
        """Log une action sur les vouchers"""
        self.log(
            action=action,
            category=LogCategory.VOUCHER,
            level=LogLevel.INFO,
            admin_id=admin_id,
            description=description,
            target_type="voucher",
            extra_data={"voucher_code": voucher_code, **(extra_data or {})} if voucher_code else extra_data
        )

    def log_admin_action(
        self,
        admin_id: int,
        action: str,
        target_type: str = None,
        target_id: int = None,
        ip: str = None,
        description: str = None
    ):
        """Log une action administrative"""
        self.log(
            action=action,
            category=LogCategory.ADMIN,
            level=LogLevel.INFO,
            admin_id=admin_id,
            ip_address=ip,
            description=description,
            target_type=target_type,
            target_id=target_id
        )

    def log_security_event(
        self,
        action: str,
        level: LogLevel = LogLevel.WARNING,
        ip: str = None,
        description: str = None
    ):
        """Log un événement de sécurité"""
        self.log(
            action=action,
            category=LogCategory.SECURITY,
            level=level,
            ip_address=ip,
            description=description
        )


admin_logger = AdminLogger()
