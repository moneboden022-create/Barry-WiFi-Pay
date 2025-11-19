import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  const String baseUrl = "http://127.0.0.1:8000";

  static Future<bool> login(String phone, String country, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "country": country,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<bool> register(
      String phone, String country, String password, bool business) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "country": country,
        "password": password,
        "is_business": business,
      }),
    );

    return response.statusCode == 200;
  }
}
