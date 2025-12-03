// lib/services/user_service.dart
// 👤 BARRY WI-FI - Service Utilisateur 5G

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class UserService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Headers avec authentification
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============================================================
  // 🔥 GET USER STATUS (forfait, voucher, wifi…)
  // ============================================================
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'has_active': data['has_active'] ?? false,
          'active_type': data['active_type'],
          'voucher_code': data['voucher_code'],
          'voucher_type': data['voucher_type'],
          'remaining_minutes': data['remaining_minutes'],
          'expires_at': data['expires_at'],
          'start_at': data['start_at'],
          'wifi_active': data['wifi_active'],
        };
      }

      return {
        'has_active': false,
        'remaining_minutes': 0,
        'wifi_active': false,
      };
    } catch (e) {
      return {
        'has_active': false,
        'remaining_minutes': 0,
        'wifi_active': false,
        'error': e.toString(),
      };
    }
  }

  // ============================================================
  // 👤 GET USER PROFILE
  // ============================================================
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ============================================================
  // ✏️ UPDATE USER PROFILE
  // ============================================================
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarPath,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (avatarPath != null) body['avatar'] = avatarPath;

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      }
      return {'success': false, 'message': 'Erreur de mise à jour'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ============================================================
  // 📊 GET USER STATS
  // ============================================================
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // ============================================================
  // 📜 GET USER HISTORY
  // ============================================================
  static Future<List<Map<String, dynamic>>> getHistory({int limit = 50}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/history?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        return List<Map<String, dynamic>>.from(data['history'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
