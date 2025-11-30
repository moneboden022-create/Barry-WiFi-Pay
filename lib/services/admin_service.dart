// lib/services/admin_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token.dart';

class AdminService {
  // Base (pointé sur ton FastAPI : prefix "/api" + router prefix "/admin")
  static const String baseUrl = "http://127.0.0.1:8000/api/admin";

  // Utilise un token admin si disponible, sinon le token normal
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

  // --- UTIL — lit le body JSON en sécurité ---
  static dynamic _safeDecodeBody(http.Response res) {
    try {
      return json.decode(res.body);
    } catch (e) {
      return null;
    }
  }

  // --- STATS ---
  // Retourne map complète ou map vide en cas d'erreur
  static Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse("$baseUrl/stats");
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        if (body is Map<String, dynamic>) return body;
        return {};
      } else {
        // gestion erreurs
        return {
          "error": "HTTP ${res.statusCode}",
          "message": _safeDecodeBody(res) ?? res.body
        };
      }
    } catch (e) {
      return {"error": "exception", "message": e.toString()};
    }
  }

  // --- USERS ---
  // Retourne structure: { count: int, users: List<Map> }
  static Future<Map<String, dynamic>> getUsers({String? q, int limit = 100, int offset = 0}) async {
    final params = <String, String>{'limit': '$limit', 'offset': '$offset'};
    if (q != null && q.isNotEmpty) params['q'] = q;
    final url = Uri.parse("$baseUrl/users").replace(queryParameters: params);
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        if (body is Map<String, dynamic>) {
          return {
            "count": body['count'] ?? 0,
            "users": body['users'] ?? <dynamic>[]
          };
        }
      }
      return {"count": 0, "users": <dynamic>[], "error": "HTTP ${res.statusCode}", "message": _safeDecodeBody(res) ?? res.body};
    } catch (e) {
      return {"count": 0, "users": <dynamic>[], "error": "exception", "message": e.toString()};
    }
  }

  // --- CONNECTIONS ---
  // Retourne { count: int, connections: List }
  static Future<Map<String, dynamic>> getConnections({int limit = 500, int offset = 0}) async {
    final url = Uri.parse("$baseUrl/connections").replace(queryParameters: {'limit': '$limit', 'offset': '$offset'});
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        if (body is Map<String, dynamic>) {
          return {
            "count": body['count'] ?? 0,
            "connections": body['connections'] ?? <dynamic>[]
          };
        }
      }
      return {"count": 0, "connections": <dynamic>[], "error": "HTTP ${res.statusCode}", "message": _safeDecodeBody(res) ?? res.body};
    } catch (e) {
      return {"count": 0, "connections": <dynamic>[], "error": "exception", "message": e.toString()};
    }
  }

  // --- VOUCHERS (list) ---
  static Future<Map<String, dynamic>> getVouchers({int limit = 200, int offset = 0}) async {
    final url = Uri.parse("$baseUrl/vouchers").replace(queryParameters: {'limit': '$limit', 'offset': '$offset'});
    try {
      final res = await http.get(url, headers: _headers());
      if (res.statusCode == 200) {
        final body = _safeDecodeBody(res);
        if (body is Map<String, dynamic>) {
          return {
            "count": body['count'] ?? 0,
            "vouchers": body['vouchers'] ?? <dynamic>[]
          };
        }
      }
      return {"count": 0, "vouchers": <dynamic>[], "error": "HTTP ${res.statusCode}", "message": _safeDecodeBody(res) ?? res.body};
    } catch (e) {
      return {"count": 0, "vouchers": <dynamic>[], "error": "exception", "message": e.toString()};
    }
  }

  // --- GENERER VOUCHER ---
  // Ton backend admin.py n'a pas de POST '/vouchers/create' — si tu as une route pour créer,
  // adapte l'URL ici. Sinon je propose d'ajouter une route backend pour créer un voucher.
  //
  // Cette méthode tente POST /vouchers/create (tu peux modifier l'URL selon ton backend).
  static Future<Map<String, dynamic>> generateVoucher({Map<String, dynamic>? payload}) async {
    // Par défaut payload vide (backend peut générer avec valeurs par défaut)
    final url = Uri.parse("$baseUrl/vouchers/create");
    try {
      final res = await http.post(url, headers: _headers(), body: json.encode(payload ?? {}));
      final body = _safeDecodeBody(res);
      if (res.statusCode == 200 || res.statusCode == 201) {
        // retourne l'objet JSON complet si présent
        return {"ok": true, "data": body ?? {}};
      } else {
        return {"ok": false, "error": "HTTP ${res.statusCode}", "message": body ?? res.body};
      }
    } catch (e) {
      return {"ok": false, "error": "exception", "message": e.toString()};
    }
  }

  // --- AUTRES UTILITAIRES (ex: router status) ---
  static Future<Map<String, dynamic>> getRouterStatus() async {
    final url = Uri.parse("$baseUrl/system/router-status");
    try {
      final res = await http.get(url, headers: _headers());
      final body = _safeDecodeBody(res);
      if (res.statusCode == 200) {
        return body is Map<String, dynamic> ? body : {"ok": false, "message": "Malformed response"};
      } else {
        return {"ok": false, "error": "HTTP ${res.statusCode}", "message": body ?? res.body};
      }
    } catch (e) {
      return {"ok": false, "error": "exception", "message": e.toString()};
    }
  }
}
