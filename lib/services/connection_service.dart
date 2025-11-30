// lib/services/connection_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/connection_model.dart';

class ConnectionService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<ConnectionModel>> getConnections() async {
    final url = Uri.parse("$baseUrl/api/admin/connections");
    final http.Response res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception("Erreur serveur: ${res.statusCode}");
    }

    final data = jsonDecode(res.body);
    final list = data is List ? data : data["data"] ?? [];

    return (list as List)
        .map((e) => ConnectionModel.fromJson(e))
        .toList();
  }
}
