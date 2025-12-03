// lib/screens/admin/admin_stats_screen.dart

import 'package:flutter/material.dart';

class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Statistiques"),
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: const Center(
        child: Text(
          "Statistiques avancées",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
