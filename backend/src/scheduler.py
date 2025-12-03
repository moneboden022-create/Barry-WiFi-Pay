import asyncio
from datetime import datetime
from sqlalchemy import select, update

from .db import SessionLocal
from .models import WifiAccess, ConnectionHistory
from .services.network.providers import WifiNetworkManager

# Manager réseau (Starlink / Mikrotik / TP-Link / SSH)
wifi = WifiNetworkManager()


async def revoke_expired_wifi_loop():
    """
    🔁 Vérification automatique toutes les 60 minutes.
    Cette tâche :
      - Trouve les WifiAccess expirés
      - Désactive Internet
      - Met à jour la base
      - Ferme l'historique de connexion proprement

    Elle est lancée dans main.py :
        asyncio.create_task(revoke_expired_wifi_loop())
    """

    while True:
        try:
            with SessionLocal() as db:
                now = datetime.utcnow()

                # -------------------------
                # 1. Récupération des accès expirés
                # -------------------------
                expired_access = db.execute(
                    select(WifiAccess).where(
                        WifiAccess.active == True,
                        WifiAccess.end_date <= now
                    )
                ).scalars().all()

                for access in expired_access:
                    user_id = access.user_id
                    print(f"[Scheduler] 🔒 Expiration détectée → User {user_id}")

                    # -------------------------
                    # 2. Désactivation via routeur
                    # -------------------------
                    ok, msg = wifi.deactivate_wifi(user_id)
                    print(f"[Scheduler] Router disable: {ok} - {msg}")

                    # -------------------------
                    # 3. Mise à jour WifiAccess
                    # -------------------------
                    db.execute(
                        update(WifiAccess)
                        .where(WifiAccess.id == access.id)
                        .values(
                            active=False,
                            updated_at=now
                        )
                    )

                    # -------------------------
                    # 4. Fermeture de la dernière session historique
                    # -------------------------
                    last_session = db.query(ConnectionHistory).filter(
                        ConnectionHistory.user_id == user_id,
                        ConnectionHistory.end_at == None
                    ).order_by(ConnectionHistory.start_at.desc()).first()

                    if last_session:
                        last_session.end_at = now
                        last_session.note = "Expiration automatique"
                        db.commit()
                        print(f"[Scheduler] ⏳ Connexion session terminée pour user {user_id}")

                db.commit()

        except Exception as e:
            print(f"[Scheduler ERROR] {e}")

        # -------------------------
        # 5. Pause 1 heure
        # -------------------------
        await asyncio.sleep(60 * 60)
