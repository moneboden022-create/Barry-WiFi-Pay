// lib/services/connection_service.dart
// 📡 BARRY WI-FI - Service de Connexion 5G

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/connection_model.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ConnectionService {
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
  // 📋 Récupérer les connexions
  // ============================================================
  static Future<List<ConnectionModel>> getConnections() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/connections'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final list = data is List ? data : data['data'] ?? [];

      return (list as List)
          .map((e) => ConnectionModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Erreur de récupération des connexions: $e');
    }
  }

  // ============================================================
  // 🔒 Bloquer un appareil
  // ============================================================
  static Future<bool> blockDevice(String deviceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/devices/$deviceId/block'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 🔓 Débloquer un appareil
  // ============================================================
  static Future<bool> unblockDevice(String deviceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/devices/$deviceId/unblock'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 📴 Désactiver le Wi-Fi pour un utilisateur
  // ============================================================
  static Future<bool> disableWifiForUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users/$userId/disable-wifi'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 📊 Statistiques de connexion
  // ============================================================
  static Future<Map<String, dynamic>> getConnectionStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/connections/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // ============================================================
  // 🔍 Historique d'un utilisateur
  // ============================================================
  static Future<List<ConnectionModel>> getUserHistory(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/connections'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);
      final list = data is List ? data : data['data'] ?? [];

      return (list as List)
          .map((e) => ConnectionModel.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
