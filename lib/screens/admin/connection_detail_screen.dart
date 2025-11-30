// lib/screens/admin/connection_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/connection_model.dart';
import '../../services/connection_service.dart';

class ConnectionDetailScreen extends StatefulWidget {
  final ConnectionModel conn;
  const ConnectionDetailScreen({super.key, required this.conn});

  @override
  State<ConnectionDetailScreen> createState() => _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends State<ConnectionDetailScreen> {
  bool working = false;

  Future<void> _blockDevice() async {
    setState(() => working = true);
    final ok = await ConnectionService.blockDevice(widget.conn.deviceId);
    setState(() => working = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? "Appareil bloqué" : "Erreur blocage")));
  }

  Future<void> _unblockDevice() async {
    setState(() => working = true);
    final ok = await ConnectionService.unblockDevice(widget.conn.deviceId);
    setState(() => working = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? "Appareil débloqué" : "Erreur")));
  }

  Future<void> _disableWifi() async {
    setState(() => working = true);
    final ok = await ConnectionService.disableWifiForUser(widget.conn.userId);
    setState(() => working = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? "Wi-Fi désactivé pour l'utilisateur" : "Erreur")));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conn;
    return Scaffold(
      appBar: AppBar(title: const Text("Détail connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(c.success ? Icons.check_circle : Icons.error, color: c.success ? Colors.green : Colors.red, size: 36),
              const SizedBox(width: 12),
              Expanded(child: Text(c.ip, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 12),
            Text("User ID: ${c.userId}"),
            Text("Device ID: ${c.deviceId}"),
            Text("User Agent: ${c.userAgent}"),
            if (c.voucherCode != null) Text("Voucher: ${c.voucherCode}"),
            Text("Début: ${c.startAt}"),
            if (c.endAt != null) Text("Fin: ${c.endAt}"),
            if (c.note != null) Text("Note: ${c.note}"),

            const SizedBox(height: 20),
            if (working) const LinearProgressIndicator(),
            const SizedBox(height: 10),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: working ? null : _blockDevice,
                  icon: const Icon(Icons.block),
                  label: const Text("Bloquer appareil"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: working ? null : _unblockDevice,
                  icon: const Icon(Icons.check),
                  label: const Text("Débloquer"),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: working ? null : _disableWifi,
                  icon: const Icon(Icons.wifi_off),
                  label: const Text("Désactiver Wi-Fi user"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
