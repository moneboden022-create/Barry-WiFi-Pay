import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool loading = true;

  Map<String, dynamic> stats = {};
  List<dynamic> users = [];
  List<dynamic> connections = [];

  String message = "";

  @override
  void initState() {
    super.initState();
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    setState(() => loading = true);

    stats = await AdminService.getStats();

    final usersData = await AdminService.getUsers();
    users = usersData["users"] ?? [];

    final connData = await AdminService.getConnections();
    connections = connData["connections"] ?? [];

    setState(() => loading = false);
  }

  Future<void> createVoucher() async {
    setState(() => message = "Création du voucher...");
    final result = await AdminService.generateVoucher();

    // → Conversion obligatoire
    setState(() => message = result.toString());
  }

  @override
  Widget build(BuildContext context) {
    final subActive = stats["subscriptions"]?["active"]?.toString() ?? "0";
    final vouchersCreated = stats["vouchers"]?["created"]?.toString() ?? "0";
    final totalUsers = stats["users"]?.toString() ?? "0";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: loadAdminData,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _statCard("Utilisateurs", totalUsers, Icons.people),
                _statCard("Abonnements actifs", subActive, Icons.wifi),
                _statCard("Vouchers créés", vouchersCreated, Icons.card_giftcard),

                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: createVoucher,
                  icon: const Icon(Icons.add),
                  label: const Text("Créer un voucher"),
                ),

                if (message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 30),
                const Text("Utilisateurs", style: TextStyle(fontSize: 20)),

                ...users.map(
                  (u) => ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(u["phone_number"] ?? ""),
                    subtitle: Text("ID: ${u["id"]}"),
                  ),
                ),

                const SizedBox(height: 30),
                const Text("Connexions", style: TextStyle(fontSize: 20)),

                ...connections.map(
                  (c) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text("Début : ${c["start_at"] ?? "?"}"),
                    subtitle: Text("Fin : ${c["end_at"] ?? "En cours"}"),
                  ),
                )
              ],
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(blurRadius: 5, offset: Offset(0, 3), color: Colors.black12),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(.2),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}
