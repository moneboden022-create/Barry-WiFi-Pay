// 🔐 BARRY WI-FI - Service d'Authentification 5ème Génération

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart'; // 🔥 IMPORTANT : Nouvelle architecture API
import 'auth_token.dart'; // 🔥 Token global en mémoire
import 'device_service.dart'; // 🔥 Service pour obtenir le device_id

class AuthService {
  // URL principale : FastAPI backend
  static String get baseUrl => ApiConfig.baseUrl;

  // ============================================================
  // 🔑 Connexion unifiée (email OU téléphone)
  // ============================================================
  static Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      // 🔥 Récupérer le device_id
      final deviceId = await getDeviceId();
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'X-Device-ID': deviceId,  // 🔥 Envoyer le device_id dans les headers
        },
        body: jsonEncode({
          'identifier': identifier,  // 🔥 Accepte email OU téléphone
          'password': password,
        }),
      );

      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 Sauvegarde du token
        final accessToken = data['access_token'];
        await prefs.setString('auth_token', accessToken);
        
        // 🔥 Mise à jour du token global en mémoire
        AuthToken.token = accessToken;
        
        // Sauvegarde des infos utilisateur
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('user_first_name', data['user']['first_name'] ?? '');
        await prefs.setString('user_last_name', data['user']['last_name'] ?? '');
        await prefs.setString('user_phone', data['user']['phone_number'] ?? '');
        await prefs.setString('user_country', data['user']['country'] ?? 'GN');
        await prefs.setBool('is_business', data['user']['isBusiness'] ?? false);
        await prefs.setString('avatar', data['user']['avatar'] ?? '');
        
        // 🔥 Vérifier si l'utilisateur est admin
        final isAdmin = data['user']['is_admin'] ?? false;
        await prefs.setBool('is_admin', isAdmin);

        return {'success': true, 'data': data};
      }

      final error = jsonDecode(response.body);
      final errorMessage = error['detail'] ?? error['message'] ?? 'Erreur de connexion';
      
      // 🔥 Gestion spéciale pour les erreurs de limite
      if (errorMessage.contains('Limite de 3 appareils admin atteinte')) {
        return {
          'success': false,
          'message': 'Limite de 3 appareils admin atteinte.',
          'is_admin_limit_error': true
        };
      }
      
      if (errorMessage.contains('Ce compte utilise déjà un appareil')) {
        return {
          'success': false,
          'message': 'Ce compte utilise déjà un appareil.',
          'is_device_limit_error': true
        };
      }
      
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Impossible de se connecter au serveur'};
    }
  }

  // ============================================================
  // 📝 Inscription
  // ============================================================
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String country,
    required String password,
    String? avatarPath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phone,
          'country': country,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['access_token']);
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('user_first_name', firstName);
        await prefs.setString('user_last_name', lastName);
        await prefs.setString('user_phone', phone);
        await prefs.setString('user_country', country);

        if (avatarPath != null) {
          await prefs.setString('avatar', avatarPath);
        }

        return {'success': true, 'data': data};
      }

      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['detail'] ?? 'Erreur lors de l’inscription',
      };
    } catch (e) {
      return {'success': false, 'message': 'Erreur de communication avec le serveur'};
    }
  }

  // ============================================================
  // 🔓 Déconnexion
  // ============================================================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  // ============================================================
  // 🔍 Vérifier si connecté
  // ============================================================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // ============================================================
  // 👤 Infos utilisateur
  // ============================================================
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('user_id'),
      'first_name': prefs.getString('user_first_name'),
      'last_name': prefs.getString('user_last_name'),
      'phone': prefs.getString('user_phone'),
      'country': prefs.getString('user_country'),
      'avatar': prefs.getString('avatar'),
      'is_business': prefs.getBool('is_business') ?? false,
    };
  }

  // ============================================================
  // 🔄 Mot de passe oublié
  // ============================================================
  static Future<Map<String, dynamic>> forgotPassword(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Code envoyé'};
      }

      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['detail'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Problème réseau'};
    }
  }

  // ============================================================
  // 🔐 Réinitialiser le mot de passe
  // ============================================================
  static Future<Map<String, dynamic>> resetPassword(
    String code,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Mot de passe changé'};
      }

      final error = jsonDecode(response.body);
      return {'success': false, 'message': error['detail'] ?? 'Erreur'};
    } catch (e) {
      return {'success': false, 'message': 'Problème réseau'};
    }
  }

  // ============================================================
  // 🔑 Récupérer le token d'authentification (FIABLE)
  // ============================================================
  static Future<String?> getToken() async {
    // 🔥 Priorité au token admin s'il existe
    if (AuthToken.adminToken != null && AuthToken.adminToken!.isNotEmpty) {
      return AuthToken.adminToken;
    }
    
    // 🔥 Sinon token normal en mémoire
    if (AuthToken.token != null && AuthToken.token!.isNotEmpty) {
      return AuthToken.token;
    }
    
    // 🔥 Sinon récupérer depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    // Mettre à jour le token en mémoire si trouvé
    if (token != null && token.isNotEmpty) {
      AuthToken.token = token;
    }
    
    return token;
  }

  // ============================================================
  // 🔐 Vérifier si l'utilisateur est admin (FIABLE)
  // ============================================================
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  // ============================================================
  // 🔄 Initialiser les tokens depuis le stockage persistant
  // ============================================================
  static Future<void> initializeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Récupérer le token normal
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      AuthToken.token = token;
    }
    
    // Récupérer le token admin
    final adminToken = prefs.getString('admin_token');
    if (adminToken != null && adminToken.isNotEmpty) {
      AuthToken.adminToken = adminToken;
    }
  }

  // ============================================================
  // 🔄 Rafraîchir le token
  // ============================================================
  static Future<bool> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        final newToken = data['access_token'];
        await prefs.setString('auth_token', newToken);
        
        // 🔥 Mettre à jour le token en mémoire
        AuthToken.token = newToken;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
