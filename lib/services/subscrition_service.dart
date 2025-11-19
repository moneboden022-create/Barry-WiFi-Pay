// lib/services/subscription_service.dart
import 'dart:convert';
import 'api_client.dart';

enum PaymentProvider { orangeMoney, mtnMoney, paypal, visa, other }

extension PaymentProviderName on PaymentProvider {
  String get apiValue {
    switch (this) {
      case PaymentProvider.orangeMoney:
        return 'ORANGE_MONEY';
      case PaymentProvider.mtnMoney:
        return 'MTN_MONEY';
      case PaymentProvider.paypal:
        return 'PAYPAL';
      case PaymentProvider.visa:
        return 'VISA';
      case PaymentProvider.other:
        return 'OTHER';
    }
  }
}

class Plan {
  final int id;
  final String name;
  final int durationMinutes;
  final double priceGNF;
  final bool isBusiness;

  Plan({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priceGNF,
    required this.isBusiness,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      durationMinutes: json['duration_minutes'],
      priceGNF: (json['price_gnf'] as num).toDouble(),
      isBusiness: json['is_business'],
    );
  }
}

class SubscriptionInfo {
  final Plan plan;
  final int remainingMinutes;

  SubscriptionInfo({
    required this.plan,
    required this.remainingMinutes,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      plan: Plan.fromJson(json['plan']),
      remainingMinutes: json['remaining_minutes'],
    );
  }
}

class SubscriptionService {
  static Future<List<Plan>> fetchPlans() async {
    final res = await ApiClient.get('/plans');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Plan.fromJson(e)).toList();
    }
    throw Exception('Impossible de charger les forfaits');
  }

  static Future<SubscriptionInfo?> getCurrent() async {
    final res = await ApiClient.get('/subscriptions/current');
    if (res.statusCode == 200 && res.body != 'null') {
      final data = jsonDecode(res.body);
      return SubscriptionInfo.fromJson(data);
    }
    return null;
  }

  static Future<SubscriptionInfo> purchase({
    required int planId,
    required PaymentProvider provider,
  }) async {
    final res = await ApiClient.post('/subscriptions/purchase', {
      'plan_id': planId,
      'provider': provider.apiValue,
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return SubscriptionInfo.fromJson(data);
    }
    throw Exception('Achat impossible');
  }
}
