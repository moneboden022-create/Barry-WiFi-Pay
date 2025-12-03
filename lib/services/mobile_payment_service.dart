// lib/services/mobile_payment_service.dart
// Service de Paiement Mobile Money - BARRY WiFi
// TODO: Payment integration - Orange Money & MTN Money

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_token.dart';

/// Service pour les paiements mobile money (Orange Money, MTN Money)
/// 
/// TODO: Payment integration
/// - Intégrer l'API Orange Money Guinée
/// - Intégrer l'API MTN Mobile Money
/// - Gérer les callbacks de paiement
class MobilePaymentService {
  static const String baseUrl = "http://127.0.0.1:8000/api/payments";

  static Map<String, String> _headers() {
    final token = AuthToken.token;
    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// Récupère les tarifs disponibles
  static Future<Map<String, dynamic>> getPricing() async {
    try {
      final url = Uri.parse("$baseUrl/pricing");
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Initie un paiement mobile money
  /// 
  /// TODO: Payment integration
  /// Cette méthode sera mise à jour pour intégrer les vraies APIs
  static Future<Map<String, dynamic>> initiatePayment({
    required int amount,
    required String method, // orange_money, mtn_money
    required String phoneNumber,
    int? planId,
    String? voucherType,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/initiate");
      final res = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          "amount": amount,
          "currency": "GNF",
          "method": method,
          "phone_number": phoneNumber,
          if (planId != null) "plan_id": planId,
          if (voucherType != null) "voucher_type": voucherType,
        }),
      );

      final body = jsonDecode(res.body);
      
      if (res.statusCode == 200) {
        return {"ok": true, "data": body};
      }
      return {"ok": false, "error": body["detail"] ?? "Erreur de paiement"};
    } catch (e) {
      return {"ok": false, "error": e.toString()};
    }
  }

  /// Vérifie le statut d'un paiement
  static Future<Map<String, dynamic>> checkPaymentStatus(int paymentId) async {
    try {
      final url = Uri.parse("$baseUrl/status/$paymentId");
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  /// Récupère l'historique des paiements
  static Future<Map<String, dynamic>> getPaymentHistory({int limit = 50}) async {
    try {
      final url = Uri.parse("$baseUrl/history?limit=$limit");
      final res = await http.get(url, headers: _headers());
      
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return {"count": 0, "payments": [], "error": "HTTP ${res.statusCode}"};
    } catch (e) {
      return {"count": 0, "payments": [], "error": e.toString()};
    }
  }

  /// Vérifie si le paiement mobile est disponible
  /// TODO: Retourner true quand l'intégration sera complète
  static bool isPaymentAvailable() {
    return false; // TODO: Changer à true après intégration
  }

  /// Retourne les méthodes de paiement disponibles
  static List<PaymentMethod> getAvailableMethods() {
    return [
      PaymentMethod(
        id: "orange_money",
        name: "Orange Money",
        icon: "🟠",
        ussd: "*144#",
        available: false, // TODO: Changer après intégration
      ),
      PaymentMethod(
        id: "mtn_money",
        name: "MTN Mobile Money",
        icon: "🟡",
        ussd: "*170#",
        available: false, // TODO: Changer après intégration
      ),
    ];
  }
}

/// Modèle pour une méthode de paiement
class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final String ussd;
  final bool available;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.ussd,
    required this.available,
  });
}

/// Modèle pour un plan tarifaire
class PricingPlan {
  final int id;
  final String name;
  final int durationMinutes;
  final int price;
  final int devices;

  PricingPlan({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
    required this.devices,
  });

  factory PricingPlan.fromJson(Map<String, dynamic> json) {
    return PricingPlan(
      id: json["id"],
      name: json["name"],
      durationMinutes: json["duration_minutes"],
      price: json["price"],
      devices: json["devices"],
    );
  }

  String get formattedDuration {
    if (durationMinutes < 60) return "$durationMinutes min";
    if (durationMinutes < 1440) return "${durationMinutes ~/ 60}h";
    if (durationMinutes < 10080) return "${durationMinutes ~/ 1440} jour(s)";
    return "${durationMinutes ~/ 10080} semaine(s)";
  }

  String get formattedPrice => "$price GNF";
}

