# backend/src/main.py
"""
🚀 BARRY WIFI API - Backend Professionnel 5ème Génération
Fondateur: Mamadou Mourtada Barry (MÖNÈBO DEN) - Siguiri, Guinée
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from fastapi.openapi.utils import get_openapi
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
import asyncio
import os

from .db import Base, engine, create_tables_safely

# Routers - API Publique
from .routers.auth import router as auth_router
from .routers.plans import router as plans_router
from .routers.subscriptions import router as subscriptions_router
from .routers.wifi import router as wifi_router
from .routers.voucher import router as voucher_router
from .routers.user import router as user_router

# Routers - API Admin
from .routers.admin import router as admin_router
from .routers.admin_auth import router as admin_auth_router
from .routers.admin_stats import router as admin_stats_router
from .routers.admin_vouchers import router as admin_vouchers_router
from .routers.geolocation import router as geolocation_router
from .routers.payments_mobile import router as payments_router  # TODO: Payment integration

# Middleware
from .middleware.rate_limiter import rate_limiter
from .middleware.security_middleware import SecurityMiddleware

# Scheduler (expiration automatique)
from .scheduler import revoke_expired_wifi_loop


# ============================================================
# INITIALISATION BASE DE DONNÉES (CORRIGÉ)
# ============================================================
create_tables_safely()


# ============================================================
# APP
# ============================================================
app = FastAPI(
    title="BARRY WIFI API",
    description="""
    🚀 **API Professionnelle BARRY WiFi Pay - 5ème Génération**
    
    Système complet de gestion WiFi par vouchers avec:
    - 🔐 Authentification sécurisée JWT
    - 🎟️ Gestion de vouchers
    - 📊 Dashboard Admin
    - 📱 Paiements mobile (Orange/MTN – futur)
    - 🌍 Géolocalisation légale (opt-in)
    - 🛡️ Protection anti-bruteforce
    """,
    version="5.0.0",
    swagger_ui_parameters={"persistAuthorization": True},
)

bearer_scheme = HTTPBearer()


# ============================================================
# PROTECTION ANTI-BRUTEFORCE
# ============================================================
@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    allowed, message = await rate_limiter.check_rate_limit(request)
    if not allowed:
        return JSONResponse(status_code=429, content={"detail": message})
    response = await call_next(request)
    return response


app.add_middleware(SecurityMiddleware)


# ============================================================
# CORS
# ============================================================
ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS if ALLOWED_ORIGINS != ["*"] else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# FICHIERS STATIQUES (Avatars)
# ============================================================
app.mount("/static", StaticFiles(directory="uploads"), name="static")


# ============================================================
# ROUTES
# ============================================================
# API publique
app.include_router(auth_router, prefix="/api")
app.include_router(plans_router, prefix="/api")
app.include_router(subscriptions_router, prefix="/api")
app.include_router(wifi_router, prefix="/api")
app.include_router(voucher_router, prefix="/api")
app.include_router(user_router, prefix="/api")
app.include_router(geolocation_router, prefix="/api")

# API Admin
app.include_router(admin_auth_router, prefix="/api")
app.include_router(admin_router, prefix="/api")
app.include_router(admin_stats_router, prefix="/api")
app.include_router(admin_vouchers_router, prefix="/api")

# Paiements (futur)
app.include_router(payments_router, prefix="/api")


# ============================================================
# HOME
# ============================================================
@app.get("/")
def root():
    return {
        "message": "🚀 Backend BARRY WIFI opérationnel",
        "version": "5.0.0",
        "status": "online",
        "founder": "Mamadou Mourtada Barry (MÖNÈBO DEN)",
        "location": "Siguiri, Guinée"
    }


# ============================================================
# HEALTH CHECK
# ============================================================
@app.get("/health")
def health_check():
    return {"status": "healthy", "database": "connected", "version": "5.0.0"}


# ============================================================
# INFOS API
# ============================================================
@app.get("/api/info")
def api_info():
    return {
        "name": "BARRY WIFI API",
        "version": "5.0.0",
        "features": [
            "Authentification JWT",
            "Vouchers",
            "Dashboard Admin",
            "Paiements",
            "Géolocalisation",
            "Anti-bruteforce"
        ]
    }


# ============================================================
# SWAGGER CUSTOM
# ============================================================
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="BARRY WIFI API",
        version="5.0.0",
        description="Backend officiel BARRY WIFI Pay",
        routes=app.routes,
    )

    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {"type": "http", "scheme": "bearer", "bearerFormat": "JWT"}
    }
    openapi_schema["security"] = [{"BearerAuth": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


# ============================================================
# SCHEDULER
# ============================================================
@app.on_event("startup")
async def startup_event():
    asyncio.create_task(revoke_expired_wifi_loop())
    print("=" * 60)
    print("🚀 BARRY WIFI API - Version 5.0.0")
    print("👤 Fondateur: Mamadou Mourtada Barry (MÖNÈBO DEN)")
    print("📍 Siguiri, Guinée")
    print("[Scheduler] Vérification des expirations démarrée")
    print("=" * 60)
