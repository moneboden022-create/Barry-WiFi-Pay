# backend/src/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
from fastapi.openapi.utils import get_openapi
from fastapi.staticfiles import StaticFiles
import asyncio

from .db import Base, engine

# Routers
from .routers.auth import router as auth_router
from .routers.plans import router as plans_router
from .routers.subscriptions import router as subscriptions_router
from .routers.wifi import router as wifi_router
from .routers.voucher import router as voucher_router
from .routers.admin import router as admin_router
from .routers.user import router as user_router      # ✅ ICI

# Scheduler (expiration automatique)
from .scheduler import revoke_expired_wifi_loop


# ============================================================
# INITIALISATION BASE DE DONNÉES
# ============================================================
Base.metadata.create_all(bind=engine)

# ============================================================
# APP
# ============================================================
app = FastAPI(
    title="BARRY WIFI API",
    description="API professionnelle BARRY WiFi Pay (Plans, Vouchers, Connexion Internet, Dashboard Admin)",
    version="2.0.0",
    swagger_ui_parameters={"persistAuthorization": True},
)

bearer_scheme = HTTPBearer()

# ============================================================
# CORS (Flutter, Web, Android, iOS)
# ============================================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# FICHIERS STATIQUES (Avatars utilisateurs)
# ============================================================
app.mount("/static", StaticFiles(directory="uploads"), name="static")

# ============================================================
# ROUTES
# ============================================================
app.include_router(auth_router, prefix="/api")
app.include_router(plans_router, prefix="/api")
app.include_router(subscriptions_router, prefix="/api")
app.include_router(wifi_router, prefix="/api")
app.include_router(voucher_router, prefix="/api")
app.include_router(admin_router, prefix="/api")
app.include_router(user_router, prefix="/api")      # ✅ AJOUT FINAL

# ============================================================
# HOME
# ============================================================
@app.get("/")
def root():
    return {"message": "Backend BARRY WIFI opérationnel"}


# ============================================================
# CUSTOM SWAGGER (JWT Bearer)
# ============================================================
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema

    openapi_schema = get_openapi(
        title="BARRY WIFI API",
        version="2.0.0",
        description="API professionnelle : login, vouchers, plans, activation Wi-Fi, dashboard admin",
        routes=app.routes,
    )

    openapi_schema["components"]["securitySchemes"] = {
        "BearerAuth": {
            "type": "http",
            "scheme": "bearer",
            "bearerFormat": "JWT",
        }
    }
    openapi_schema["security"] = [{"BearerAuth": []}]

    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi

# ============================================================
# SCHEDULER — Détection automatique des expirations Wi-Fi
# ============================================================
@app.on_event("startup")
async def startup_event():
    asyncio.create_task(revoke_expired_wifi_loop())
    print("[Scheduler] Vérification automatique des expirations Wi-Fi démarrée…")
