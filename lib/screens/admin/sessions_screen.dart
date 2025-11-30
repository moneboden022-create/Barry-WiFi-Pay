import 'package:flutter/material.dart';
import 'package:barry_wifi_pay/services/admin_service.dart';
import 'package:barry_wifi_pay/models/admin_models.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late Future<List<Session>> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = AdminService.getSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sessions")),
      body: FutureBuilder<List<Session>>(
        future: _sessions,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Erreur : ${snap.error}"));
          }

          final data = snap.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("Aucune session"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final s = data[i];
              return ListTile(
                title: Text(s.device),
                subtitle: Text("IP : ${s.ip}"),
              );
            },
          );
        },
      ),
    );
  }
}
