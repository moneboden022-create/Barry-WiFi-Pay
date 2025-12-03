// lib/services/voucher_service.dart
// 🎟️ Service Voucher pour les utilisateurs - BARRY WiFi

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'auth_token.dart';

class VoucherService {
  /// 🎫 Utiliser un voucher (activer une connexion)
  static Future<String> useVoucher(String code) async {
    // 🔥 Récupérer le token de manière fiable
    final token = await AuthService.getToken();
    
    // 🔥 Vérifier que le token existe
    if (token == null || token.isEmpty) {
      return 'Erreur : Non authentifié. Veuillez vous reconnecter.';
    }

    // URL CORRECTE : /api/voucher/use
    final url = Uri.parse('${AuthService.baseUrl}/voucher/use');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        return 'Activation réussie !';
      }
      
      // 🔥 Gestion erreur 401 - Non authentifié
      if (response.statusCode == 401) {
        // Essayer de rafraîchir le token
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          // Réessayer avec le nouveau token
          return await useVoucher(code);
        }
        return 'Erreur : Session expirée. Veuillez vous reconnecter.';
      }

      // Essayer de récupérer le message d'erreur envoyé par le backend
      try {
        final data = jsonDecode(response.body);
        return 'Erreur : ${data["detail"] ?? response.body}';
      } catch (_) {
        return 'Erreur inconnue (${response.statusCode})';
      }
    } catch (e) {
      return 'Erreur de connexion : $e';
    }
  }
  
  /// 🔍 Vérifier un voucher sans l'utiliser
  static Future<Map<String, dynamic>> checkVoucher(String code) async {
    final token = await AuthService.getToken();
    
    if (token == null || token.isEmpty) {
      return {'success': false, 'error': 'Non authentifié'};
    }
    
    final url = Uri.parse('${AuthService.baseUrl}/voucher/check');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      
      final error = jsonDecode(response.body);
      return {'success': false, 'error': error['detail'] ?? 'Voucher invalide'};
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion'};
    }
  }
}
