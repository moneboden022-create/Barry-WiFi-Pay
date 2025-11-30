// lib/widgets/connection_tile.dart

import 'package:flutter/material.dart';
import '../models/connection_model.dart';

class ConnectionTile extends StatelessWidget {
  final ConnectionModel c;

  const ConnectionTile({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.wifi),
      title: Text(c.device),
      subtitle: Text("IP : ${c.ip}"),
    );
  }
}
