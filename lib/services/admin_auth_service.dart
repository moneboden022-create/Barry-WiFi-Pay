// lib/services/admin_auth_service.dart
// Service d'authentification Admin séparé pour BARRY WiFi

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_token.dart';

class AdminAuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api/admin/auth";
  static const _storage = FlutterSecureStorage();
  
  // Code admin master
  static const String _adminCodeKey = 'admin_code';
  static const String _adminTokenKey = 'admin_token';
  static const String _adminRoleKey = 'admin_role';
  static const String _adminNameKey = 'admin_name';
  
  /// Login admin avec double authentification
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
    required String adminCode,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/login");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone_number": phone,
          "password": password,
          "admin_code": adminCode,
        }),
      );
      
      final body = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Stocker les tokens
        final accessToken = body["access_token"];
        final adminRole = body["admin_role"];
        final userName = body["user_name"];
        
        await _storage.write(key: _adminTokenKey, value: accessToken);
        await _storage.write(key: _adminRoleKey, value: adminRole);
        await _storage.write(key: _adminNameKey, value: userName);
        
        // Mettre à jour le token global
        AuthToken.adminToken = accessToken;
        AuthToken.token = accessToken;
        
        return {
          "success": true,
          "is_admin": true,
          "admin_role": adminRole,
          "user_name": userName,
          "user_id": body["user_id"],
        };
      } else {
        return {
          "success": false,
          "error": body["detail"] ?? "Erreur de connexion admin",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "error": "Connexion impossible: $e",
      };
    }
  }
  
  /// Vérifier si une session admin est active
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _adminTokenKey);
    return token != null && token.isNotEmpty;
  }
  
  /// Récupérer le token admin
  static Future<String?> getToken() async {
    return await _storage.read(key: _adminTokenKey);
  }
  
  /// Récupérer le rôle admin
  static Future<String?> getRole() async {
    return await _storage.read(key: _adminRoleKey);
  }
  
  /// Récupérer le nom admin
  static Future<String?> getName() async {
    return await _storage.read(key: _adminNameKey);
  }
  
  /// Vérifier la session admin auprès du serveur
  static Future<Map<String, dynamic>> verifySession() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {"valid": false, "error": "Pas de token"};
      }
      
      final url = Uri.parse("$baseUrl/verify");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          "valid": true,
          "admin_role": body["admin_role"],
          "name": body["name"],
        };
      } else {
        return {"valid": false, "error": "Session expirée"};
      }
    } catch (e) {
      return {"valid": false, "error": e.toString()};
    }
  }
  
  /// Déconnexion admin
  static Future<void> logout() async {
    await _storage.delete(key: _adminTokenKey);
    await _storage.delete(key: _adminRoleKey);
    await _storage.delete(key: _adminNameKey);
    AuthToken.adminToken = null;
  }
  
  /// Liste des admins (super_admin only)
  static Future<List<Map<String, dynamic>>> listAdmins() async {
    try {
      final token = await getToken();
      final url = Uri.parse("$baseUrl/list");
      
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(body["admins"] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

