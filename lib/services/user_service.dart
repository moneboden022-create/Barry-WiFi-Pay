// lib/services/user_service.dart

import 'package:barrywifi/services/api_client.dart';

class UserService {
  // --------------------------------------------------------
  //   🔥 GET USER STATUS (forfait, voucher, wifi…)
  // --------------------------------------------------------
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final data = await ApiClient.get("/user/status");

      // 🔥 Réponse formatée pour ton UI
      return {
        "has_active": data["has_active"] ?? false,
        "active_type": data["active_type"],
        "voucher_code": data["voucher_code"],
        "voucher_type": data["voucher_type"],
        "remaining_minutes": data["remaining_minutes"],
        "expires_at": data["expires_at"],
        "start_at": data["start_at"],
        "wifi_active": data["wifi_active"],
      };
    } catch (e) {
      print("❌ UserService.getStatus ERROR: $e");
      return {
        "has_active": false,
        "remaining_minutes": 0,
        "wifi_active": false,
      };
    }
  }
}
