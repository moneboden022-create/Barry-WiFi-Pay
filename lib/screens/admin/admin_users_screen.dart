// lib/screens/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<dynamic>> _users;

  @override
  void initState() {
    super.initState();
    _users = _loadUsers();
  }

  Future<List<dynamic>> _loadUsers() async {
    final res = await AdminService.getUsers();
    return res["users"] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Utilisateurs")),
      body: FutureBuilder<List<dynamic>>(
        future: _users,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final users = snap.data!;
          if (users.isEmpty) return const Center(child: Text("Aucun utilisateur"));

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final u = users[i];

              return ListTile(
                title: Text("${u["first_name"]} ${u["last_name"]}"),
                subtitle: Text(u["phone_number"] ?? ""),
                trailing: Icon(Icons.person),
              );
            },
          );
        },
      ),
    );
  }
}
