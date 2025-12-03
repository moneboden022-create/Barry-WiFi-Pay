// lib/screens/admin/admin_zones_screen.dart

import 'package:flutter/material.dart';

class AdminZonesScreen extends StatelessWidget {
  const AdminZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Zones"),
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: const Center(
        child: Text(
          "Gestion des zones WiFi",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
