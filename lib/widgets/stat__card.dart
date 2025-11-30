// lib/widgets/stat_card.dart
import 'package:flutter/material.dart';
import '../models/admin_models.dart';

class StatCard extends StatelessWidget {
  final Stat stat;
  const StatCard({Key? key, required this.stat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(stat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${stat.value}', style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
