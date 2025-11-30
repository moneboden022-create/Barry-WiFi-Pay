// lib/services/settings_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token.dart';
import 'auth_storage.dart';

class SettingsService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Get stored token (from AuthToken or storage)
  static Future<String?> _getToken() async {
    if (AuthToken.token != null) return AuthToken.token;
    final t = await AuthStorage.loadToken();
    if (t != null) AuthToken.token = t;
    return t;
  }

  // Update profile on backend
  static Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String country,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/auth/profile/update');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone,
        'country': country,
      }),
    );
    return response.statusCode == 200;
  }

  // Change password
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await _getToken();
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/auth/change-password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    return response.statusCode == 200;
  }

  // Get profile (optional)
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await _getToken();
    if (token == null) return null;
    final url = Uri.parse('$baseUrl/auth/me');
    final r = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (r.statusCode == 200) return jsonDecode(r.body);
    return null;
  }
}
