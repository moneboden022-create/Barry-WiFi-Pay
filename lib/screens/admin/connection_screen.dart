// lib/screens/admin/connections_screen.dart

import 'package:flutter/material.dart';
import '../../services/connection_service.dart';
import '../../models/connection_model.dart';
import '../../widgets/connection_tile.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  late Future<List<ConnectionModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ConnectionService.getConnections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historique des connexions")),
      body: FutureBuilder<List<ConnectionModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text("Erreur : ${snap.error}"),
            );
          }

          final data = snap.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text("Aucune connexion trouvée"),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) => ConnectionTile(c: data[i]),
          );
        },
      ),
    );
  }
}
