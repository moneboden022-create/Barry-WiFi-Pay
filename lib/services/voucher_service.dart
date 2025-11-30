// lib/services/voucher_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class VoucherService {
  static Future<String> useVoucher(String code) async {
    // Récupérer le token déjà stocké lors du login
    final token = await AuthService.getToken();

    // URL CORRECTE : /api/voucher/use
    final url = Uri.parse('${AuthService.baseUrl}/voucher/use');

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

    // Essayer de récupérer le message d’erreur envoyé par le backend
    try {
      final data = jsonDecode(response.body);
      return 'Erreur : ${data["detail"] ?? response.body}';
    } catch (_) {
      return 'Erreur inconnue (${response.statusCode})';
    }
  }
}
