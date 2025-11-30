// lib/screens/admin/history_screen.dart
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> history = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      history = await AdminService.getHistory();
    } catch (e) {
      error = e.toString();
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique connexions')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Erreur: $error'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, i) {
                      final e = history[i] as Map<String, dynamic>;
                      final user = e['user'] ?? 'inconnu';
                      final action = e['action'] ?? e['status'] ?? 'event';
                      final at = e['created_at'] ?? e['timestamp'] ?? '';
                      final extra = e['ip'] ?? e['device'] ?? '';
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text('$user — $action'),
                        subtitle: Text('$extra\n$at'),
                        isThreeLine: true,
                      );
                    },
                  ),
      ),
    );
  }
}
