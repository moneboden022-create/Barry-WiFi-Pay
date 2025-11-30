// lib/widgets/session_tile.dart
import 'package:flutter/material.dart';
import '../models/admin_models.dart';

class SessionTile extends StatelessWidget {
  final Session session;
  const SessionTile({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.devices),
      title: Text(session.device),
      subtitle: Text('IP: ${session.ip}'),
      trailing: Text('${DateTime.fromMillisecondsSinceEpoch(session.createdAt * 1000)}', style: const TextStyle(fontSize: 11)),
    );
  }
}
