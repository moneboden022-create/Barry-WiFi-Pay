// lib/services/wifi_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class WifiService {
  /// GET WiFi Status
  static Future<bool> getStatus() async {
    try {
      final http.Response res = await ApiClient.get("/api/wifi/status");

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);
      return data["active"] == true;
    } catch (e) {
      return false;
    }
  }

  /// ACTIVATE WiFi
  static Future<bool> activate() async {
    try {
      final http.Response res =
          await ApiClient.post("/api/wifi/activate", {});

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// DEACTIVATE WiFi
  static Future<bool> deactivate() async {
    try {
      final http.Response res =
          await ApiClient.post("/api/wifi/deactivate", {});

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
