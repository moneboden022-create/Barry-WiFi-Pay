import datetime

class WifiNetworkManager:
    """
    Gère l’activation et la désactivation du Wi-Fi selon la durée d’abonnement.
    (Simulation — version réelle pourra se connecter à ton routeur ou API.)
    """

    def __init__(self):
        self.active_connections = {}  # {user_id: end_date}

    def activate_wifi(self, user_id: str, duration_days: int):
        end_date = datetime.datetime.now() + datetime.timedelta(days=duration_days)
        self.active_connections[user_id] = end_date
        print(f"✅ Wi-Fi activé pour {user_id} jusqu'au {end_date.strftime('%d/%m/%Y %H:%M:%S')}")
        return {"status": "activated", "end_date": str(end_date)}

    def deactivate_wifi(self, user_id: str):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
            print(f"🚫 Wi-Fi désactivé pour {user_id}")
            return {"status": "deactivated"}
        return {"status": "already_off"}

    def check_wifi_status(self, user_id: str):
        now = datetime.datetime.now()
        end_date = self.active_connections.get(user_id)

        if end_date and now < end_date:
            remaining = end_date - now
            return {"status": "active", "remaining_days": remaining.days}
        else:
            if user_id in self.active_connections:
                del self.active_connections[user_id]
            return {"status": "expired"}
