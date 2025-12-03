// lib/services/admin_auth_service.dart
// Service d'authentification Admin séparé pour BARRY WiFi

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_token.dart';

class AdminAuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api/admin/auth";
  static const _storage = FlutterSecureStorage();
  
  // Clés de stockage
  static const String _adminTokenKey = 'admin_token';
  static const String _adminRoleKey = 'admin_role';
  static const String _adminNameKey = 'admin_name';
  
  /// 🔐 Login admin avec double authentification (email OU téléphone)
  /// Sauvegarde le token dans FlutterSecureStorage ET SharedPreferences
  static Future<Map<String, dynamic>> login({
    required String identifier,  // 🔥 Email OU téléphone
    required String password,
    required String adminCode,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/login");
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": identifier,  // 🔥 Champ unifié
          "password": password,
          "admin_code": adminCode,
        }),
      );
      
      final body = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // 🔥 Récupérer les données
        final accessToken = body["access_token"];
        final adminRole = body["admin_role"] ?? "admin";
        final userName = body["user_name"] ?? "";
        final userId = body["user_id"];
        
        // 🔥 1. Stocker dans FlutterSecureStorage
        await _storage.write(key: _adminTokenKey, value: accessToken);
        await _storage.write(key: _adminRoleKey, value: adminRole);
        await _storage.write(key: _adminNameKey, value: userName);
        
        // 🔥 2. Stocker dans SharedPreferences (pour compatibilité avec AuthService)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', accessToken);
        await prefs.setString('admin_token', accessToken);
        await prefs.setBool('is_admin', true);
        await prefs.setString('admin_role', adminRole);
        await prefs.setString('admin_name', userName);
        if (userId != null) {
          await prefs.setInt('user_id', userId);
        }
        
        // 🔥 3. Mettre à jour le token global en mémoire
        AuthToken.adminToken = accessToken;
        AuthToken.token = accessToken;
        
        return {
          "success": true,
          "is_admin": true,
          "admin_role": adminRole,
          "user_name": userName,
          "user_id": userId,
          "access_token": accessToken,
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
  
  /// 🔍 Vérifier si une session admin est active
  static Future<bool> isLoggedIn() async {
    // 🔥 Vérifier d'abord en mémoire
    if (AuthToken.adminToken != null && AuthToken.adminToken!.isNotEmpty) {
      return true;
    }
    
    // 🔥 Sinon vérifier dans le stockage sécurisé
    final token = await _storage.read(key: _adminTokenKey);
    if (token != null && token.isNotEmpty) {
      // Restaurer en mémoire
      AuthToken.adminToken = token;
      AuthToken.token = token;
      return true;
    }
    
    // 🔥 Sinon vérifier dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final adminToken = prefs.getString('admin_token');
    if (adminToken != null && adminToken.isNotEmpty) {
      AuthToken.adminToken = adminToken;
      AuthToken.token = adminToken;
      return true;
    }
    
    return false;
  }
  
  /// 🔐 Vérifier si l'utilisateur est admin (FIABLE)
  static Future<bool> isAdmin() async {
    // 🔥 Vérifier si connecté
    final isConnected = await isLoggedIn();
    if (!isConnected) return false;
    
    // 🔥 Vérifier le flag is_admin dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }
  
  /// 🔑 Récupérer le token admin (FIABLE)
  static Future<String?> getToken() async {
    // 🔥 Priorité au token en mémoire
    if (AuthToken.adminToken != null && AuthToken.adminToken!.isNotEmpty) {
      return AuthToken.adminToken;
    }
    
    // 🔥 Sinon FlutterSecureStorage
    final secureToken = await _storage.read(key: _adminTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      AuthToken.adminToken = secureToken;
      return secureToken;
    }
    
    // 🔥 Sinon SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final prefsToken = prefs.getString('admin_token');
    if (prefsToken != null && prefsToken.isNotEmpty) {
      AuthToken.adminToken = prefsToken;
      return prefsToken;
    }
    
    return null;
  }
  
  /// Récupérer le rôle admin
  static Future<String?> getRole() async {
    final role = await _storage.read(key: _adminRoleKey);
    if (role != null) return role;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_role');
  }
  
  /// Récupérer le nom admin
  static Future<String?> getName() async {
    final name = await _storage.read(key: _adminNameKey);
    if (name != null) return name;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('admin_name');
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
  
  /// 🚪 Déconnexion admin
  static Future<void> logout() async {
    // 🔥 Supprimer de FlutterSecureStorage
    await _storage.delete(key: _adminTokenKey);
    await _storage.delete(key: _adminRoleKey);
    await _storage.delete(key: _adminNameKey);
    
    // 🔥 Supprimer de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.setBool('is_admin', false);
    await prefs.remove('admin_role');
    await prefs.remove('admin_name');
    
    // 🔥 Effacer les tokens en mémoire
    AuthToken.adminToken = null;
    // Note: on ne supprime pas AuthToken.token car l'utilisateur peut rester connecté en tant qu'utilisateur normal
  }
  
  /// 🔄 Initialiser les tokens admin depuis le stockage
  static Future<void> initializeTokens() async {
    // 🔥 Essayer de récupérer le token admin
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      AuthToken.adminToken = token;
      AuthToken.token = token;
    }
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

