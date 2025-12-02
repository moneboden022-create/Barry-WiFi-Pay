# backend/src/middleware/admin_logs.py
"""
📝 Système de logs administratifs pour BARRY WiFi
Trace toutes les actions importantes pour la sécurité et l'audit
"""

from datetime import datetime
from typing import Optional, List, Dict, Any
from enum import Enum
from sqlalchemy.orm import Session
from sqlalchemy import Column, Integer, String, DateTime, Text, Enum as SQLEnum
from ..db import Base, SessionLocal
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


class AdminLog(Base):
    """Modèle SQLAlchemy pour les logs administratifs"""
    __tablename__ = "admin_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    
    level = Column(String(20), default="INFO")
    category = Column(String(30), default="SYSTEM")
    
    action = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)
    
    user_id = Column(Integer, nullable=True, index=True)
    admin_id = Column(Integer, nullable=True, index=True)
    
    ip_address = Column(String(45), nullable=True)
    ip_hash = Column(String(64), nullable=True)  # Pour anonymisation RGPD
    user_agent = Column(String(500), nullable=True)
    
    request_path = Column(String(255), nullable=True)
    request_method = Column(String(10), nullable=True)
    
    extra_data = Column(Text, nullable=True)  # JSON pour données supplémentaires
    
    # Pour les actions sensibles
    target_type = Column(String(50), nullable=True)  # user, voucher, device, etc.
    target_id = Column(Integer, nullable=True)


class AdminLogger:
    """
    Gestionnaire de logs administratifs.
    
    Usage:
        admin_logger.log(
            action="user_blocked",
            category=LogCategory.SECURITY,
            level=LogLevel.WARNING,
            user_id=123,
            admin_id=1,
            description="Utilisateur bloqué pour activité suspecte"
        )
    """
    
    def __init__(self):
        self._buffer: List[Dict] = []
        self._buffer_size = 10
    
    def _hash_ip(self, ip: str) -> str:
        """Hash l'IP pour la confidentialité RGPD"""
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
        """
        Enregistre un log administratif.
        """
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
        
        if db:
            db.add(log_entry)
            db.commit()
        else:
            # Utiliser une session séparée
            try:
                with SessionLocal() as session:
                    session.add(log_entry)
                    session.commit()
            except Exception as e:
                # Fallback: print en cas d'erreur DB
                print(f"[LOG {level}] {category}: {action} - {description}")
    
    def log_auth_success(self, user_id: int, ip: str, user_agent: str = None):
        """Log une connexion réussie"""
        self.log(
            action="login_success",
            category=LogCategory.AUTH,
            level=LogLevel.INFO,
            user_id=user_id,
            ip_address=ip,
            user_agent=user_agent,
            description=f"Connexion réussie pour user #{user_id}"
        )
    
    def log_auth_failed(self, phone: str, ip: str, reason: str = "invalid_credentials"):
        """Log une tentative de connexion échouée"""
        self.log(
            action="login_failed",
            category=LogCategory.AUTH,
            level=LogLevel.WARNING,
            ip_address=ip,
            description=f"Tentative échouée pour {phone[:4]}*** - {reason}",
            extra_data={"phone_partial": phone[:4] + "***", "reason": reason}
        )
    
    def log_admin_action(
        self,
        admin_id: int,
        action: str,
        target_type: str = None,
        target_id: int = None,
        description: str = None,
        ip: str = None
    ):
        """Log une action admin"""
        self.log(
            action=action,
            category=LogCategory.ADMIN,
            level=LogLevel.INFO,
            admin_id=admin_id,
            target_type=target_type,
            target_id=target_id,
            ip_address=ip,
            description=description
        )
    
    def log_security_event(
        self,
        action: str,
        level: LogLevel = LogLevel.WARNING,
        ip: str = None,
        description: str = None,
        extra_data: dict = None
    ):
        """Log un événement de sécurité"""
        self.log(
            action=action,
            category=LogCategory.SECURITY,
            level=level,
            ip_address=ip,
            description=description,
            extra_data=extra_data
        )
    
    def log_voucher_action(
        self,
        action: str,
        voucher_code: str = None,
        user_id: int = None,
        admin_id: int = None,
        description: str = None
    ):
        """Log une action voucher"""
        self.log(
            action=action,
            category=LogCategory.VOUCHER,
            level=LogLevel.INFO,
            user_id=user_id,
            admin_id=admin_id,
            target_type="voucher",
            description=description,
            extra_data={"voucher_code": voucher_code} if voucher_code else None
        )
    
    def get_recent_logs(
        self,
        db: Session,
        limit: int = 100,
        category: LogCategory = None,
        level: LogLevel = None,
        user_id: int = None,
        admin_id: int = None
    ) -> List[AdminLog]:
        """Récupère les logs récents avec filtres optionnels"""
        query = db.query(AdminLog).order_by(AdminLog.timestamp.desc())
        
        if category:
            query = query.filter(AdminLog.category == category.value)
        if level:
            query = query.filter(AdminLog.level == level.value)
        if user_id:
            query = query.filter(AdminLog.user_id == user_id)
        if admin_id:
            query = query.filter(AdminLog.admin_id == admin_id)
        
        return query.limit(limit).all()
    
    def get_security_alerts(self, db: Session, hours: int = 24) -> List[AdminLog]:
        """Récupère les alertes de sécurité récentes"""
        from datetime import timedelta
        cutoff = datetime.utcnow() - timedelta(hours=hours)
        
        return db.query(AdminLog).filter(
            AdminLog.category == LogCategory.SECURITY.value,
            AdminLog.timestamp >= cutoff
        ).order_by(AdminLog.timestamp.desc()).all()


# Instance globale
admin_logger = AdminLogger()

