import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import 'device_service.dart';

final baseUrl = 'http://127.0.0.1:8000/api'; // adapte en prod

Future<Map> login(String phone, String password) async {
  final resp = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phone_number': phone, 'password': password}),
  );
  return jsonDecode(resp.body);
}

Future<Map> useVoucher(String code) async {
  final token = await readToken();
  final deviceId = await getDeviceId();
  final resp = await http.post(
    Uri.parse('$baseUrl/voucher/use'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Device-ID': deviceId,
    },
    body: jsonEncode({'code': code}),
  );
  return jsonDecode(resp.body);
}

Future<Map> buyPlan(int planId) async {
  final token = await readToken();
  final deviceId = await getDeviceId();
  final resp = await http.post(
    Uri.parse('$baseUrl/subscriptions/buy?plan_id=$planId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'X-Device-ID': deviceId,
    },
  );
  return jsonDecode(resp.body);
}

Future<Map> activateWifi() async {
  final token = await readToken();
  final deviceId = await getDeviceId();
  final resp = await http.post(
    Uri.parse('$baseUrl/wifi/activate'),
    headers: {
      'Authorization': 'Bearer $token',
      'X-Device-ID': deviceId,
    },
  );
  return jsonDecode(resp.body);
}
