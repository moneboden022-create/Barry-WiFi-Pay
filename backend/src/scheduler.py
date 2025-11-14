
import asyncio
from datetime import datetime
from sqlalchemy import select, update
from src.db import SessionLocal
from src.models import WifiAccess
from src.services.network.providers import WifiNetworkManager

wifi = WifiNetworkManager()

async def revoke_expired_wifi_loop():
    """
    Boucle asynchrone qui vérifie toutes les 60 minutes les accès expirés.
    Désactive le Wi-Fi et met à jour la DB.
    """
    while True:
        try:
            with SessionLocal() as db:
                now = datetime.utcnow()
                rows = db.execute(
                    select(WifiAccess).where(WifiAccess.active == True, WifiAccess.end_date <= now)
                ).scalars().all()

                for row in rows:
                    wifi.deactivate_wifi(row.user_id)
                    db.execute(
                        update(WifiAccess)
                        .where(WifiAccess.id == row.id)
                        .values(active=False, updated_at=now)
                    )
                db.commit()
        except Exception as e:
            print("Scheduler error:", e)

        await asyncio.sleep(60 * 60)  # toutes les 60 minutes