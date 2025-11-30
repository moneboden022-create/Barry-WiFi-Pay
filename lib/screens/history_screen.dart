import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // plus tard : brancher à ton backend (liste des abonnements / connexions)
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.wifi),
            title: Text("Pass 1 heure"),
            subtitle: Text("12/11/2025 • 10:30"),
            trailing: Text("1000 GNF"),
          ),
          ListTile(
            leading: Icon(Icons.wifi),
            title: Text("Pass 2 heures"),
            subtitle: Text("11/11/2025 • 20:15"),
            trailing: Text("2000 GNF"),
          ),
        ],
      ),
    );
  }
}
