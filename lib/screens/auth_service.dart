import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token.dart';

class AdminService {
  static const String baseUrl = "http://127.0.0.1:8000/api/admin";

  static Map<String, String> _headers() {
    final token = AuthToken.adminToken?.isNotEmpty == true
        ? AuthToken.adminToken
        : AuthToken.token;

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static dynamic _decode(http.Response res) {
    try {
      return json.decode(res.body);
    } catch (_) {
      return null;
    }
  }

  // ---------- STATS ----------
  static Future<Map<String, dynamic>> getStats() async {
    final res = await http.get(Uri.parse("$baseUrl/stats"), headers: _headers());

    if (res.statusCode == 200) return _decode(res);

    return {"error": res.statusCode};
  }

  // ---------- USERS ----------
  static Future<Map<String, dynamic>> getUsers() async {
    final res = await http.get(Uri.parse("$baseUrl/users"), headers: _headers());

    if (res.statusCode == 200) return _decode(res);

    return {"count": 0, "users": []};
  }

  // ---------- CONNECTIONS ----------
  static Future<Map<String, dynamic>> getConnections() async {
    final res = await http.get(Uri.parse("$baseUrl/connections"), headers: _headers());

    if (res.statusCode == 200) return _decode(res);

    return {"count": 0, "connections": []};
  }

  // ---------- VOUCHER ----------
  static Future<String> generateVoucher() async {
    final res = await http.post(
      Uri.parse("$baseUrl/voucher/create"),
      headers: _headers(),
    );

    if (res.statusCode == 200) {
      final data = _decode(res);
      return data["voucher"] ?? "OK";
    } else {
      return "Erreur ${res.statusCode}";
    }
  }
}
