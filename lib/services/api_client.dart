// lib/services/api_client.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Ton backend local
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static String? _token;

  // ------ TOKEN ------
  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  // ------ HEADERS ------
  static Map<String, String> _headers() {
    final headers = {
      "Content-Type": "application/json",
    };

    // Ajouter JWT automatiquement si présent
    if (_token != null) {
      headers["Authorization"] = "Bearer $_token";
    }
    return headers;
  }

  // ------ GET ------
  static Future<dynamic> get(String path) async {
    try {
      final url = Uri.parse("$baseUrl$path");
      final resp = await http.get(url, headers: _headers());
      return _decode(resp);
    } catch (e) {
      throw ApiException(500, "Connexion impossible");
    }
  }

  // ------ POST ------
  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse("$baseUrl$path");
      final resp = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode(body),
      );
      return _decode(resp);
    } catch (e) {
      throw ApiException(500, "Connexion impossible");
    }
  }

  // ------ DÉCODEUR COMMUN ------
  static dynamic _decode(http.Response resp) {
    final code = resp.statusCode;

    // si backend renvoie JSON vide
    if (resp.body.isEmpty) return null;

    final body = jsonDecode(resp.body);

    if (code >= 200 && code < 300) {
      return body;
    }

    // Gestion standard FastAPI : "detail"
    final msg = (body is Map && body["detail"] != null)
        ? body["detail"].toString()
        : "Erreur serveur";

    throw ApiException(code, msg);
  }
}

// ------ EXCEPTION ------
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => "ApiException ($statusCode): $message";
}
