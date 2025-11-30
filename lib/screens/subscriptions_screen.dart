import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool loading = true;
  Map<String, dynamic>? subscription;

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    try {
      setState(() => loading = true);

      final url = Uri.parse("http://127.0.0.1:8000/api/subscriptions/mine/");

      final res = await http.get(url, headers: {
        "Authorization": "Bearer TON_TOKEN",
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data is List && data.isNotEmpty) {
          setState(() => subscription = data.last);
        }
      }
    } catch (e) {
      print("Erreur API: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon abonnement")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : subscription == null
                ? const Center(child: Text("Aucun abonnement actif"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Plan : ${subscription!["plan"]?["name"] ?? "Inconnu"}",
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Expire le : ${subscription!["end_at"] ?? "-"}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: fetchSubscriptions,
                        child: const Text("Rafraîchir"),
                      )
                    ],
                  ),
      ),
    );
  }
}
