import 'dart:convert';
import '../services/api_client.dart';
import 'package:http/http.dart' as http;

class SubscriptionService {
  static Future<String> buyPlan(int planId) async {
    final http.Response res =
        await ApiClient.post("/subscriptions/buy", {"plan_id": planId});

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return "Succès : ${data["message"]}";
    } else {
      return "Erreur : ${data["detail"]}";
    }
  }

  static Future<String> buyCustom(int minutes) async {
    final http.Response res = await ApiClient.post("/subscriptions/buy", {
      "plan_id": 0,
      "custom_minutes": minutes,
    });

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return "Succès : ${data["message"]}";
    } else {
      return "Erreur : ${data["detail"]}";
    }
  }
}
