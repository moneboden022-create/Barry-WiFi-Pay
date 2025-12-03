// lib/screens/admin/admin_connections_screen.dart

import 'package:flutter/material.dart';

class AdminConnectionsScreen extends StatelessWidget {
  const AdminConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Connexions"),
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: const Center(
        child: Text(
          "Historique des connexions",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
