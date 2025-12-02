# backend/src/middleware/security_middleware.py
"""
🛡️ Security Middleware pour BARRY WiFi
Protection contre injections, XSS, et autres attaques
"""

import re
from fastapi import Request, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware
from typing import List, Pattern


class SecurityMiddleware(BaseHTTPMiddleware):
    """
    Middleware de sécurité avancée.
    
    Features:
    - Validation des entrées
    - Protection contre les injections SQL
    - Protection XSS
    - Filtrage des headers dangereux
    - Vérification de la taille des requêtes
    """
    
    # Patterns dangereux pour injection SQL
    SQL_INJECTION_PATTERNS: List[Pattern] = [
        re.compile(r"(\%27)|(\')|(\-\-)|(\%23)|(#)", re.IGNORECASE),
        re.compile(r"((\%3D)|(=))[^\n]*((\%27)|(\')|(\-\-)|(\%3B)|(;))", re.IGNORECASE),
        re.compile(r"\w*((\%27)|(\'))((\%6F)|o|(\%4F))((\%72)|r|(\%52))", re.IGNORECASE),
        re.compile(r"((\%27)|(\'))union", re.IGNORECASE),
        re.compile(r"exec(\s|\+)+(s|x)p\w+", re.IGNORECASE),
        re.compile(r"UNION\s+SELECT", re.IGNORECASE),
        re.compile(r"SELECT\s+.*\s+FROM", re.IGNORECASE),
        re.compile(r"INSERT\s+INTO", re.IGNORECASE),
        re.compile(r"DELETE\s+FROM", re.IGNORECASE),
        re.compile(r"DROP\s+TABLE", re.IGNORECASE),
    ]
    
    # Patterns XSS
    XSS_PATTERNS: List[Pattern] = [
        re.compile(r"<script[^>]*>.*?</script>", re.IGNORECASE | re.DOTALL),
        re.compile(r"javascript:", re.IGNORECASE),
        re.compile(r"on\w+\s*=", re.IGNORECASE),
        re.compile(r"<iframe", re.IGNORECASE),
        re.compile(r"<object", re.IGNORECASE),
        re.compile(r"<embed", re.IGNORECASE),
    ]
    
    # Taille maximale du body (10 MB)
    MAX_BODY_SIZE = 10 * 1024 * 1024
    
    # Headers de sécurité à ajouter
    SECURITY_HEADERS = {
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "DENY",
        "X-XSS-Protection": "1; mode=block",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Permissions-Policy": "geolocation=(self), microphone=()",
    }
    
    def __init__(self, app, exclude_paths: List[str] = None):
        super().__init__(app)
        self.exclude_paths = exclude_paths or ["/docs", "/redoc", "/openapi.json"]
    
    async def dispatch(self, request: Request, call_next):
        # Ignorer certains paths
        if any(request.url.path.startswith(p) for p in self.exclude_paths):
            return await call_next(request)
        
        # 1. Vérifier la taille de la requête
        content_length = request.headers.get("content-length")
        if content_length and int(content_length) > self.MAX_BODY_SIZE:
            raise HTTPException(413, "Requête trop volumineuse")
        
        # 2. Vérifier les paramètres de l'URL
        query_string = str(request.url.query)
        if query_string:
            if self._check_injection(query_string):
                raise HTTPException(400, "Paramètres URL invalides")
            if self._check_xss(query_string):
                raise HTTPException(400, "Contenu non autorisé détecté")
        
        # 3. Vérifier le path
        if self._check_injection(request.url.path):
            raise HTTPException(400, "Chemin invalide")
        
        # 4. Exécuter la requête
        response = await call_next(request)
        
        # 5. Ajouter les headers de sécurité
        for header, value in self.SECURITY_HEADERS.items():
            response.headers[header] = value
        
        return response
    
    def _check_injection(self, text: str) -> bool:
        """Vérifie si le texte contient des patterns d'injection SQL"""
        for pattern in self.SQL_INJECTION_PATTERNS:
            if pattern.search(text):
                return True
        return False
    
    def _check_xss(self, text: str) -> bool:
        """Vérifie si le texte contient des patterns XSS"""
        for pattern in self.XSS_PATTERNS:
            if pattern.search(text):
                return True
        return False


def validate_input(value: str, max_length: int = 255, allow_special: bool = False) -> str:
    """
    Valide et nettoie une entrée utilisateur.
    
    Args:
        value: Valeur à valider
        max_length: Longueur maximale
        allow_special: Autoriser les caractères spéciaux
    
    Returns:
        Valeur nettoyée
    
    Raises:
        HTTPException si invalide
    """
    if not value:
        return value
    
    # Limiter la longueur
    if len(value) > max_length:
        raise HTTPException(400, f"Valeur trop longue (max {max_length} caractères)")
    
    # Nettoyer les espaces
    value = value.strip()
    
    # Vérifier les caractères dangereux
    if not allow_special:
        # Supprimer les caractères HTML/JS dangereux
        dangerous_chars = ['<', '>', '"', "'", '&', '\\', '\x00']
        for char in dangerous_chars:
            value = value.replace(char, '')
    
    return value


def validate_phone(phone: str) -> str:
    """Valide un numéro de téléphone"""
    # Supprimer les espaces et tirets
    phone = re.sub(r'[\s\-\.]', '', phone)
    
    # Vérifier le format
    if not re.match(r'^\+?[0-9]{8,15}$', phone):
        raise HTTPException(400, "Numéro de téléphone invalide")
    
    return phone


def validate_code(code: str) -> str:
    """Valide un code voucher"""
    code = code.strip().upper()
    
    # Seulement alphanumériques et tirets
    if not re.match(r'^[A-Z0-9\-]{4,20}$', code):
        raise HTTPException(400, "Code voucher invalide")
    
    return code


def sanitize_mac_address(mac: str) -> str:
    """Valide et formate une adresse MAC"""
    mac = mac.strip().upper()
    
    # Accepter différents formats
    mac = re.sub(r'[:\-\.]', '', mac)
    
    if not re.match(r'^[A-F0-9]{12}$', mac):
        raise HTTPException(400, "Adresse MAC invalide")
    
    # Formater en XX:XX:XX:XX:XX:XX
    return ':'.join(mac[i:i+2] for i in range(0, 12, 2))

