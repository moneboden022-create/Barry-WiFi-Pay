import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool loading = true;
  Map<String, dynamic>? subscription;

  Future<void> fetchSubscription() async {
    setState(() => loading = true);

    final url = Uri.parse("https://TON-SERVEUR/subscriptions/mine");

    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer TON_TOKEN",
      },
    );

    if (res.statusCode == 200) {
      List subs = jsonDecode(res.body);
      if (subs.isNotEmpty) {
        setState(() => subscription = subs.last);
      }
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    fetchSubscription();
    super.initState();
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
                        "Plan : ${subscription!["plan"]?["name"] ?? "Voucher"}",
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Expire : ${subscription!["end_at"]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("Rafraîchir"),
                      )
                    ],
                  ),
      ),
    );
  }
}
