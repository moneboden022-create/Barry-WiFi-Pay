import 'package:flutter/material.dart';
import 'package:barry_wifi/services/admin_service.dart';
import 'package:barry_wifi/models/admin_models.dart';
import 'package:barry_wifi/widgets/stat_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<List<Stat>> _stats;

  @override
  void initState() {
    super.initState();
    _stats = AdminService.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin - Dashboard")),
      body: FutureBuilder<List<Stat>>(
        future: _stats,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Erreur : ${snap.error}"));
          }

          final stats = snap.data ?? [];

          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(12),
            children: stats.map((s) => StatCard(stat: s)).toList(),
          );
        },
      ),
    );
  }
}
