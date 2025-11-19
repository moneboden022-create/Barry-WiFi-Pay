import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = "https://ton-backend.com/api";

  // *********** MOBILE MONEY PAYMENT ***********
  static Future<Map<String, dynamic>> payWithMobileMoney({
    required String phone,
    required String operator, // "orange" ou "mtn"
    required int amount,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/payments/mobile");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "operator": operator,
        "amount": amount,
        "userId": userId,
      }),
    );

    return jsonDecode(response.body);
  }

  // *********** VOUCHER PAYMENT ***********
  static Future<Map<String, dynamic>> payWithVoucher({
    required String code,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/payments/voucher");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "code": code,
        "userId": userId,
      }),
    );

    return jsonDecode(response.body);
  }

  // *********** PAYPAL ***********
  static Future<Map<String, dynamic>> payWithPayPal({
    required int amount,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/payments/paypal");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "userId": userId,
      }),
    );

    return jsonDecode(response.body);
  }

  // *********** VISA ***********
  static Future<Map<String, dynamic>> payWithVisa({
    required int amount,
    required String cardNumber,
    required String exp,
    required String cvv,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/payments/visa");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": amount,
        "cardNumber": cardNumber,
        "exp": exp,
        "cvv": cvv,
        "userId": userId,
      }),
    );

    return jsonDecode(response.body);
  }
}
