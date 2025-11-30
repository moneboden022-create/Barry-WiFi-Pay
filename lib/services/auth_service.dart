// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token.dart'; // ⭐ Très important pour stocker le token global

class AuthService {
  // Adresse du backend FastAPI
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Stockage simple du token local
  static String? token;

  // ============================================================
  // 1. LOGIN
  // ============================================================
  static Future<bool> login({
    required String phone,
    required String country,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone_number": phone,
        "country": country,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ----- STOCKAGE DU TOKEN -----
      // Certains backend renvoient "access_token", d'autres "token".
      if (data["access_token"] != null) {
        AuthToken.token = data["access_token"]; // global
        token = data["access_token"];           // local
      } else if (data["token"] != null) {
        AuthToken.token = data["token"];        // global
        token = data["token"];                  // local
      }
      // -----------------------------------------------

      return true;
    }

    return false;
  }

  // ============================================================
  // 2. REGISTER
  // ============================================================
  static Future<bool> register({
    required String phone,
    required String country,
    required String password,
    required bool isBusiness,
    required String firstName,
    required String lastName,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone_number": phone,
        "country": country,
        "password": password,
        "isBusiness": isBusiness,
        "first_name": firstName,
        "last_name": lastName,
      }),
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // 3. GET TOKEN (pour abonnement / voucher / admin)
  // ============================================================
  static Future<String?> getToken() async {
    return token;
  }

  // ============================================================
  // 4. MOT DE PASSE OUBLIÉ
  // ============================================================
  static Future<bool> forgotPassword(String phone) async {
    final url = Uri.parse("$baseUrl/auth/forgot-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone}),
    );

    return response.statusCode == 200;
  }

  // ============================================================
  // 5. RÉINITIALISATION DU MOT DE PASSE
  // ============================================================
  static Future<bool> resetPassword(
    String phone,
    String code,
    String newPassword,
  ) async {
    final url = Uri.parse("$baseUrl/auth/reset-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "code": code,
        "new_password": newPassword,
      }),
    );

    return response.statusCode == 200;
  }
}
