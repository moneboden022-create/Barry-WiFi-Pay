// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService {
  static const _tokenKey = 'barrywifi_token';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      ApiClient.setToken(token);
    }
  }

  static Future<bool> register({
    required String phone,
    required String password,
    String? country,
    bool isBusiness = false,
  }) async {
    final res = await ApiClient.post('/auth/register', {
      'phone_number': phone,
      'password': password,
      'country': country,
      'is_business': isBusiness,
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final token = data['access_token'] as String;
      ApiClient.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return true;
    }
    return false;
  }

  static Future<bool> login({
    required String phone,
    required String password,
  }) async {
    final res = await ApiClient.post('/auth/login', {
      'phone_number': phone,
      'password': password,
    });

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final token = data['access_token'] as String;
      ApiClient.setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    ApiClient.setToken('');
  }
}
