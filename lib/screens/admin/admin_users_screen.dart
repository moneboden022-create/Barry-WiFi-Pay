import 'package:flutter/material.dart';
import 'package:barry_wifi_pay/services/admin_service.dart';
import 'package:barry_wifi_pay/models/admin_models.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<AdminUser>> _users;

  @override
  void initState() {
    super.initState();
    _users = AdminService.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des utilisateurs")),
      body: FutureBuilder<List<AdminUser>>(
        future: _users,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Erreur : ${snap.error}"));
          }

          final users = snap.data ?? [];

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final u = users[i];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text("${u.firstname} ${u.lastname}"),
                subtitle: Text(u.phone),
                trailing: Switch(
                  value: u.active,
                  onChanged: (v) async {
                    final ok = await AdminService.toggleUser(u.id, v);
                    if (ok) {
                      setState(() {
                        _users = AdminService.getUsers();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erreur")),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
