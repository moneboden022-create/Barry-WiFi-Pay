// lib/screens/admin/admin_devices_screen.dart

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminDevicesScreen extends StatefulWidget {
  const AdminDevicesScreen({super.key});

  @override
  State<AdminDevicesScreen> createState() => _AdminDevicesScreenState();
}

class _AdminDevicesScreenState extends State<AdminDevicesScreen> {
  late Future<List<dynamic>> _devices;

  @override
  void initState() {
    super.initState();
    _devices = _loadDevices();
  }

  Future<List<dynamic>> _loadDevices() async {
    final res = await AdminService.getDevices();
    return res["devices"] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appareils")),
      body: FutureBuilder<List<dynamic>>(
        future: _devices,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final devices = snap.data!;
          if (devices.isEmpty) return const Center(child: Text("Aucun appareil"));

          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (ctx, i) {
              final d = devices[i];

              return ListTile(
                title: Text(d["device_name"] ?? "Device"),
                subtitle: Text("ID: ${d["id"]}"),
                trailing: Icon(
                  d["is_blocked"] == true ? Icons.block : Icons.check_circle,
                  color: d["is_blocked"] ? Colors.red : Colors.green,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
