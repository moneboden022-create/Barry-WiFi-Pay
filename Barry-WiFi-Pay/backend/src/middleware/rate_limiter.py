# backend/src/middleware/rate_limiter.py
"""
🔒 Rate Limiter + Anti-Bruteforce pour BARRY WiFi
Protection contre les attaques par force brute et DoS
"""

from fastapi import Request, HTTPException
from collections import defaultdict
from datetime import datetime, timedelta
from typing import Dict, List, Tuple
import asyncio
import hashlib


class RateLimiter:
    """
    Système de rate limiting avec protection anti-bruteforce.
    
    Features:
    - Limite de requêtes par IP
    - Blocage automatique après X tentatives échouées
    - Fenêtre glissante pour le comptage
    - Liste blanche d'IPs
    """
    
    def __init__(
        self,
        max_requests: int = 100,
        window_seconds: int = 60,
        max_failed_attempts: int = 5,
        block_duration_minutes: int = 15
    ):
        self.max_requests = max_requests
        self.window = window_seconds
        self.max_failed = max_failed_attempts
        self.block_duration = block_duration_minutes
        
        # Stockage en mémoire (pour production, utiliser Redis)
        self.requests: Dict[str, List[datetime]] = defaultdict(list)
        self.blocked_ips: Dict[str, datetime] = {}
        self.failed_attempts: Dict[str, int] = defaultdict(int)
        self.failed_endpoints: Dict[str, Dict[str, int]] = defaultdict(lambda: defaultdict(int))
        
        # IPs en liste blanche (localhost, etc.)
        self.whitelist = {"127.0.0.1", "localhost", "::1"}
    
    def _get_client_ip(self, request: Request) -> str:
        """Récupère l'IP réelle du client (support proxy)"""
        # Vérifier les headers de proxy
        forwarded = request.headers.get("X-Forwarded-For")
        if forwarded:
            return forwarded.split(",")[0].strip()
        
        real_ip = request.headers.get("X-Real-IP")
        if real_ip:
            return real_ip
        
        return request.client.host if request.client else "unknown"
    
    def _hash_ip(self, ip: str) -> str:
        """Hash l'IP pour la confidentialité dans les logs"""
        return hashlib.sha256(ip.encode()).hexdigest()[:12]
    
    async def check_rate_limit(self, request: Request) -> Tuple[bool, str]:
        """
        Vérifie le rate limit pour une requête.
        
        Returns:
            (allowed, message): True si autorisé, False sinon avec message
        """
        ip = self._get_client_ip(request)
        
        # Ignorer la liste blanche
        if ip in self.whitelist:
            return True, "whitelisted"
        
        now = datetime.utcnow()
        
        # 1. Vérifier si l'IP est bloquée (bruteforce)
        if ip in self.blocked_ips:
            if now < self.blocked_ips[ip]:
                remaining = (self.blocked_ips[ip] - now).seconds // 60
                return False, f"IP bloquée. Réessayez dans {remaining} minutes."
            else:
                # Débloquer l'IP
                del self.blocked_ips[ip]
                self.failed_attempts[ip] = 0
        
        # 2. Nettoyer les anciennes requêtes (fenêtre glissante)
        cutoff = now - timedelta(seconds=self.window)
        self.requests[ip] = [t for t in self.requests[ip] if t > cutoff]
        
        # 3. Vérifier la limite
        if len(self.requests[ip]) >= self.max_requests:
            return False, f"Limite de {self.max_requests} requêtes/{self.window}s atteinte."
        
        # 4. Enregistrer la requête
        self.requests[ip].append(now)
        
        return True, "ok"
    
    def record_failed_login(self, request: Request, endpoint: str = "/auth/login"):
        """
        Enregistre une tentative de connexion échouée.
        Bloque l'IP après max_failed tentatives.
        """
        ip = self._get_client_ip(request)
        
        if ip in self.whitelist:
            return
        
        self.failed_attempts[ip] += 1
        self.failed_endpoints[ip][endpoint] += 1
        
        if self.failed_attempts[ip] >= self.max_failed:
            self.blocked_ips[ip] = datetime.utcnow() + timedelta(minutes=self.block_duration)
            print(f"[Security] 🚫 IP {self._hash_ip(ip)} bloquée pour {self.block_duration} min (bruteforce)")
    
    def record_successful_login(self, request: Request):
        """Réinitialise le compteur après une connexion réussie"""
        ip = self._get_client_ip(request)
        self.failed_attempts[ip] = 0
    
    def is_blocked(self, request: Request) -> bool:
        """Vérifie si une IP est bloquée"""
        ip = self._get_client_ip(request)
        if ip in self.blocked_ips:
            return datetime.utcnow() < self.blocked_ips[ip]
        return False
    
    def get_stats(self) -> dict:
        """Retourne les statistiques de sécurité"""
        now = datetime.utcnow()
        return {
            "blocked_ips": len(self.blocked_ips),
            "active_ips": len(self.requests),
            "total_failed_attempts": sum(self.failed_attempts.values()),
            "blocked_list": [
                {
                    "ip_hash": self._hash_ip(ip),
                    "until": str(until),
                    "remaining_minutes": max(0, (until - now).seconds // 60)
                }
                for ip, until in self.blocked_ips.items()
                if until > now
            ]
        }
    
    def unblock_ip(self, ip: str) -> bool:
        """Débloque manuellement une IP (admin)"""
        if ip in self.blocked_ips:
            del self.blocked_ips[ip]
            self.failed_attempts[ip] = 0
            return True
        return False


# Instance globale
rate_limiter = RateLimiter(
    max_requests=100,
    window_seconds=60,
    max_failed_attempts=5,
    block_duration_minutes=15
)


# Middleware FastAPI
async def rate_limit_middleware(request: Request, call_next):
    """Middleware FastAPI pour le rate limiting"""
    allowed, message = await rate_limiter.check_rate_limit(request)
    
    if not allowed:
        raise HTTPException(status_code=429, detail=message)
    
    response = await call_next(request)
    return response

