from src.routers import admin
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import asyncio
import os

# Import internes
from src.routers import payments, wifi
from src.services.payments.adapters import PaymentService
from src.db import Base, engine
from src.scheduler import revoke_expired_wifi_loop

# ---------------------------------------------------------------
# Initialisation de l'application FastAPI
# ---------------------------------------------------------------
app = FastAPI(
    title="BARRY PayWiFi API",
    version="0.1.0",
    description="API centrale de gestion des paiements et du Wi-Fi BARRY"
)

# ---------------------------------------------------------------
# Middleware CORS
# ---------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------
# Vérification du statut du serveur
# ---------------------------------------------------------------
@app.get("/health")
def health():
    return {"status": "ok"}

# ---------------------------------------------------------------
# Enregistrement des routes principales
# ---------------------------------------------------------------
app.include_router(payments.router, prefix="/payments", tags=["payments"])
app.include_router(wifi.router, prefix="/wifi", tags=["wifi"])
app.include_router(admin.router, prefix="/admin", tags=["admin"])

# ---------------------------------------------------------------
# Service central de paiement
# ---------------------------------------------------------------
payment_service = PaymentService()

@app.get("/test_payment")
def test_payment():
    result = payment_service.process_payment(
        user_id="test_user",
        amount=5000,
        method="mock",
        plan="monthly"
    )
    return {"message": "Paiement simulé", "result": result}

# ---------------------------------------------------------------
# Initialisation de la base et du scheduler
# ---------------------------------------------------------------
@app.on_event("startup")
async def on_startup():
    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print("⚠️ DB init error (startup):", e)

    asyncio.create_task(revoke_expired_wifi_loop())