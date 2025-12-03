// lib/services/admin_service.dart
// Service Admin complet pour BARRY WiFi - Version 5G
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_token.dart';
import '../models/admin_models.dart';

class AdminService {
  static const String baseUrl = "http://127.0.0.1:8000/api/admin";
  static const String statsUrl = "http://127.0.0.1:8000/api/admin/stats";
  static const String vouchersUrl = "http://127.0.0.1:8000/api/admin/vouchers";

  /// 🔥 Récupère les headers avec le token admin de manière fiable (async)
  static Future<Map<String, String>> _getHeaders() async {
    String? token;
    
    // 🔥 1. Priorité au token admin en mémoire
    if (AuthToken.adminToken != null && AuthToken.adminToken!.isNotEmpty) {
      token = AuthToken.adminToken;
    }
    // 🔥 2. Sinon token normal en mémoire
    else if (AuthToken.token != null && AuthToken.token!.isNotEmpty) {
      token = AuthToken.token;
    }
    // 🔥 3. Sinon essayer de récupérer depuis SharedPreferences
    else {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('admin_token') ?? prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        AuthToken.adminToken = token;
      }
    }
    
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 🔄 Headers synchrones (pour compatibilité) - utilise le token en mémoire
  static Map<String, String> _headers() {
    final token = AuthToken.adminToken?.isNotEmpty == true
        ? AuthToken.adminToken
        : AuthToken.token;
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static dynamic _safeDecodeBody(http.Response res) {
    try {
      return json.decode(res.body);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // 📊 STATISTIQUES GÉNÉRALES
  // ============================================================
  
  static Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse("$baseUrl/stats");
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        if (body is Map<String, dynamic>) return body;
      }
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getOverviewStats() async {
    final url = Uri.parse("$statsUrl/overview");
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ============================================================
  // 📈 GRAPHIQUES
  // ============================================================
  
  /// Connexions par jour (graphique courbes)
  static Future<List<Map<String, dynamic>>> getDailyConnections({int days = 7}) async {
    final url = Uri.parse("$statsUrl/connections/daily?days=$days");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return List<Map<String, dynamic>>.from(body?["data"] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Inscriptions par jour (graphique barres)
  static Future<List<Map<String, dynamic>>> getUserRegistrations({int days = 30}) async {
    final url = Uri.parse("$statsUrl/users/registrations?days=$days");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return List<Map<String, dynamic>>.from(body?["data"] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Revenus par jour
  static Future<Map<String, dynamic>> getRevenueChart({int days = 30}) async {
    final url = Uri.parse("$statsUrl/revenue/chart?days=$days");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Heatmap heures de pointe
  static Future<Map<String, dynamic>> getConnectionsHeatmap({int days = 7}) async {
    final url = Uri.parse("$statsUrl/connections/heatmap?days=$days");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Répartition vouchers (pie chart)
  static Future<Map<String, dynamic>> getVouchersDistribution() async {
    final url = Uri.parse("$statsUrl/vouchers/distribution");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Comparaison hebdomadaire
  static Future<Map<String, dynamic>> getWeeklyComparison() async {
    final url = Uri.parse("$statsUrl/weekly-comparison");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ============================================================
  // 👥 UTILISATEURS
  // ============================================================
  
  static Future<Map<String, dynamic>> getUsers({String? q, int limit = 100, int offset = 0}) async {
    final params = <String, String>{'limit': '$limit', 'offset': '$offset'};
    if (q != null && q.isNotEmpty) params['q'] = q;
    final url = Uri.parse("$baseUrl/users").replace(queryParameters: params);
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "count": body?['count'] ?? 0,
          "users": body?['users'] ?? []
        };
      }
      return {"count": 0, "users": [], "error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"count": 0, "users": [], "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserDetail(int userId) async {
    final url = Uri.parse("$baseUrl/users/$userId");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<bool> deleteUser(int userId) async {
    final url = Uri.parse("$baseUrl/users/$userId");
    try {
      final res = await http.delete(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 📱 APPAREILS / DEVICES
  // ============================================================
  
  static Future<Map<String, dynamic>> getDevices({int limit = 200, int offset = 0}) async {
    final url = Uri.parse("$baseUrl/devices").replace(
      queryParameters: {'limit': '$limit', 'offset': '$offset'}
    );
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "count": body?['count'] ?? 0,
          "devices": body?['devices'] ?? []
        };
      }
      return {"count": 0, "devices": []};
    } catch (e) {
      return {"count": 0, "devices": [], "error": e.toString()};
    }
  }

  static Future<bool> blockDevice(int deviceId) async {
    final url = Uri.parse("$baseUrl/devices/block/$deviceId");
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> unblockDevice(int deviceId) async {
    final url = Uri.parse("$baseUrl/devices/unblock/$deviceId");
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 📜 CONNEXIONS / HISTORIQUE
  // ============================================================
  
  static Future<Map<String, dynamic>> getConnections({int limit = 500, int offset = 0}) async {
    final url = Uri.parse("$baseUrl/connections").replace(
      queryParameters: {'limit': '$limit', 'offset': '$offset'}
    );
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "count": body?['count'] ?? 0,
          "connections": body?['connections'] ?? []
        };
      }
      return {"count": 0, "connections": []};
    } catch (e) {
      return {"count": 0, "connections": [], "error": e.toString()};
    }
  }

  // ============================================================
  // 🎟️ VOUCHERS
  // ============================================================
  
  static Future<Map<String, dynamic>> getVouchers({
    String? status,
    String? type,
    int limit = 200,
    int offset = 0
  }) async {
    final params = <String, String>{'limit': '$limit', 'offset': '$offset'};
    if (status != null) params['status'] = status;
    if (type != null) params['type'] = type;
    
    final url = Uri.parse(vouchersUrl).replace(queryParameters: params);
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "total": body?['total'] ?? 0,
          "count": body?['count'] ?? 0,
          "vouchers": body?['vouchers'] ?? []
        };
      }
      // 🔥 Gestion erreur 401/403
      if (res.statusCode == 401 || res.statusCode == 403) {
        return {"total": 0, "count": 0, "vouchers": [], "error": "Non authentifié"};
      }
      return {"total": 0, "count": 0, "vouchers": []};
    } catch (e) {
      return {"total": 0, "count": 0, "vouchers": [], "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createVoucher({
    String type = "individual",
    int durationMinutes = 60,
    int maxDevices = 1,
    int quantity = 1,
    String? prefix,
  }) async {
    final url = Uri.parse("$vouchersUrl/create");
    try {
      final headers = await _getHeaders();
      
      // 🔥 Vérifier si le token est présent
      if (!headers.containsKey('Authorization')) {
        return {"ok": false, "error": "Non authentifié. Veuillez vous reconnecter."};
      }
      
      final res = await http.post(
        url,
        headers: headers,
        body: json.encode({
          "type": type,
          "duration_minutes": durationMinutes,
          "max_devices": maxDevices,
          "quantity": quantity,
          if (prefix != null) "prefix": prefix,
        }),
      );
      final body = _safeDecodeBody(res);
      if (res.statusCode == 200) {
        return {"ok": true, "data": body};
      }
      // 🔥 Gestion erreur 401 - Non authentifié
      if (res.statusCode == 401) {
        return {"ok": false, "error": "Session expirée. Veuillez vous reconnecter."};
      }
      // 🔥 Gestion erreur 403 - Non autorisé
      if (res.statusCode == 403) {
        return {"ok": false, "error": "Accès refusé. Droits administrateur requis."};
      }
      return {"ok": false, "error": body?["detail"] ?? "Erreur"};
    } catch (e) {
      return {"ok": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> generateVoucher({Map<String, dynamic>? payload}) async {
    return createVoucher(
      type: payload?["type"] ?? "individual",
      durationMinutes: payload?["duration_minutes"] ?? 60,
      maxDevices: payload?["max_devices"] ?? 1,
      quantity: payload?["quantity"] ?? 1,
    );
  }

  static Future<bool> deleteVoucher(int voucherId) async {
    final url = Uri.parse("$vouchersUrl/$voucherId");
    try {
      final res = await http.delete(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> disableVoucher(int voucherId) async {
    final url = Uri.parse("$vouchersUrl/$voucherId/disable");
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> enableVoucher(int voucherId) async {
    final url = Uri.parse("$vouchersUrl/$voucherId/enable");
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getVoucherStats() async {
    final url = Uri.parse("$vouchersUrl/stats/summary");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {};
      }
      return {};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ============================================================
  // 📶 WIFI ACCESS
  // ============================================================
  
  static Future<Map<String, dynamic>> getWifiAccess({int limit = 200, int offset = 0}) async {
    final url = Uri.parse("$baseUrl/wifi").replace(
      queryParameters: {'limit': '$limit', 'offset': '$offset'}
    );
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "count": body?['count'] ?? 0,
          "wifi_access": body?['wifi_access'] ?? []
        };
      }
      return {"count": 0, "wifi_access": []};
    } catch (e) {
      return {"count": 0, "wifi_access": [], "error": e.toString()};
    }
  }

  static Future<bool> disableUserWifi(int userId) async {
    final url = Uri.parse("$baseUrl/wifi/disable/$userId");
    try {
      final res = await http.post(url, headers: _headers());
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // 🔧 SYSTÈME
  // ============================================================
  
  static Future<Map<String, dynamic>> getRouterStatus() async {
    final url = Uri.parse("$baseUrl/system/router-status");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        return _safeDecodeBody(res) ?? {"ok": false};
      }
      return {"ok": false, "error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"ok": false, "error": e.toString()};
    }
  }

  // ============================================================
  // 📊 SESSIONS ACTIVES
  // ============================================================
  
  static Future<List<Session>> getSessions() async {
    final url = Uri.parse("$baseUrl/sessions");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        final list = body is List ? body : body?["sessions"] ?? [];
        return (list as List).map((e) => Session.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // 📜 HISTORIQUE GÉNÉRAL
  // ============================================================
  
  static Future<List<Map<String, dynamic>>> getHistory({int limit = 100, int offset = 0}) async {
    final url = Uri.parse("$baseUrl/history").replace(
      queryParameters: {'limit': '$limit', 'offset': '$offset'}
    );
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        final list = body is List ? body : body?["history"] ?? [];
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================================
  // 🔐 ADMIN SESSIONS
  // ============================================================
  
  /// Récupère toutes les sessions admin (tous les admins)
  static Future<Map<String, dynamic>> getAllAdminSessions() async {
    final url = Uri.parse("$baseUrl/sessions");
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "success": true,
          "sessions": body?["sessions"] ?? [],
          "count": body?["count"] ?? 0,
        };
      }
      return {
        "success": false,
        "message": "Erreur HTTP ${res.statusCode}",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
  
  /// Récupère toutes les sessions admin de l'administrateur connecté
  static Future<Map<String, dynamic>> getMyAdminSessions() async {
    final url = Uri.parse("$baseUrl/sessions/my");
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "success": true,
          "sessions": body?["sessions"] ?? [],
          "count": body?["count"] ?? 0,
        };
      }
      return {
        "success": false,
        "message": "Erreur HTTP ${res.statusCode}",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }

  /// Supprime une session admin (déconnexion à distance)
  static Future<Map<String, dynamic>> deleteAdminSession(int sessionId) async {
    final url = Uri.parse("$baseUrl/sessions/$sessionId");
    try {
      final headers = await _getHeaders();
      final res = await http.delete(url, headers: headers);
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        return {
          "success": true,
          "message": body?["message"] ?? "Session supprimée avec succès",
        };
      }
      final body = _safeDecodeBody(res);
      return {
        "success": false,
        "message": body?["detail"] ?? "Erreur HTTP ${res.statusCode}",
      };
    } catch (e) {
      return {
        "success": false,
        "message": e.toString(),
      };
    }
  }
}
