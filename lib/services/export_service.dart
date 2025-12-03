// lib/services/export_service.dart
// 📤 BARRY WI-FI - Service d'Export 5G
// Note: Les exports PDF/Excel nécessitent des packages supplémentaires

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/connection_model.dart';

class ExportService {
  /// ------------------------------------------------------------------------
  /// 🔵 1) EXPORT CSV
  /// ------------------------------------------------------------------------
  static Future<String> exportCSV(List<ConnectionModel> list, int page) async {
    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = "connections_page${page}_$stamp.csv";

    final buffer = StringBuffer();
    buffer.writeln("id,user_id,device_id,ip,voucher,start_at,end_at,success");

    for (var c in list) {
      buffer.writeln([
        c.id,
        c.userId,
        c.deviceId,
        '"${c.ip}"',
        '"${c.voucherCode ?? ""}"',
        '"${c.startAt.toIso8601String()}"',
        '"${c.endAt?.toIso8601String() ?? ""}"',
        c.success ? "1" : "0",
      ].join(","));
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// ------------------------------------------------------------------------
  /// 🟢 2) EXPORT JSON
  /// ------------------------------------------------------------------------
  static Future<String> exportJSON(List<ConnectionModel> list, int page) async {
    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = "connections_page${page}_$stamp.json";

    final jsonList = list.map((c) => c.toJson()).toList();
    final jsonString = '{"connections": $jsonList, "page": $page, "exported_at": "$now"}';

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// ------------------------------------------------------------------------
  /// 📊 3) EXPORT TXT (Simple)
  /// ------------------------------------------------------------------------
  static Future<String> exportTXT(List<ConnectionModel> list, int page) async {
    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = "connections_page${page}_$stamp.txt";

    final buffer = StringBuffer();
    buffer.writeln("=== BARRY WI-FI - Export Connexions ===");
    buffer.writeln("Page: $page");
    buffer.writeln("Date: ${DateFormat('dd/MM/yyyy HH:mm').format(now)}");
    buffer.writeln("Total: ${list.length} connexions");
    buffer.writeln("");
    buffer.writeln("=" * 50);

    for (var c in list) {
      buffer.writeln("\nID: ${c.id}");
      buffer.writeln("IP: ${c.ip}");
      buffer.writeln("User ID: ${c.userId}");
      buffer.writeln("Device: ${c.deviceId}");
      buffer.writeln("Voucher: ${c.voucherCode ?? 'N/A'}");
      buffer.writeln("Début: ${c.startAt}");
      buffer.writeln("Fin: ${c.endAt ?? 'En cours'}");
      buffer.writeln("Succès: ${c.success ? 'Oui' : 'Non'}");
      buffer.writeln("-" * 30);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsString(buffer.toString());

    return file.path;
  }

  /// ------------------------------------------------------------------------
  /// 📁 Obtenir le répertoire d'export
  /// ------------------------------------------------------------------------
  static Future<String> getExportDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory("${dir.path}/exports");
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir.path;
  }

  /// ------------------------------------------------------------------------
  /// 🗑️ Nettoyer les anciens exports
  /// ------------------------------------------------------------------------
  static Future<void> cleanOldExports({int maxAgeInDays = 30}) async {
    try {
      final exportPath = await getExportDirectory();
      final exportDir = Directory(exportPath);
      final now = DateTime.now();

      await for (var entity in exportDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified).inDays;
          if (age > maxAgeInDays) {
            await entity.delete();
          }
        }
      }
    } catch (_) {
      // Ignorer les erreurs
    }
  }
}
