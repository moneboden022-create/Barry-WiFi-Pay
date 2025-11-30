// lib/screens/connections_screen.dart

import 'package:flutter/material.dart';
import '../services/api_client.dart';
import 'dart:convert';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  bool loading = true;
  List connections = [];

  @override
  void initState() {
    super.initState();
    loadConnections();
  }

  Future<void> loadConnections() async {
    try {
      final res =
          await ApiClient.get("/api/admin/connections");
      final data = jsonDecode(res.body);

      setState(() {
        connections = data["data"] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF007BFF),
        title: const Text("Historique des Connexions"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : connections.isEmpty
              ? const Center(
                  child: Text(
                    "Aucune connexion trouvée.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final c = connections[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading:
                            const Icon(Icons.wifi, color: Colors.blue),
                        title: Text(
                            "IP : ${c['ip'] ?? 'Inconnu'}"),
                        subtitle: Text(
                          "Date : ${c['date'] ?? ''}\n"
                          "Durée : ${c['duration'] ?? 'N/A'}",
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
