// lib/services/export_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';               // XLSX
import 'package:pdf/pdf.dart';                   // PDF
import 'package:pdf/widgets.dart' as pw;         // PDF
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
    buffer.writeln("id,user_id,device_id,ip,voucher,user_agent,start_at,end_at,success,note");

    for (var c in list) {
      buffer.writeln([
        c.id,
        c.userId,
        c.deviceId,
        '"${c.ip}"',
        '"${c.voucherCode ?? ""}"',
        '"${c.userAgent.replaceAll('"', "'")}"',
        '"${c.startAt}"',
        '"${c.endAt ?? ""}"',
        c.success ? "1" : "0",
        '"${c.note ?? ""}"'
      ].join(","));
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles([XFile(file.path)], text: "Export CSV");
    return file.path;
  }

  /// ------------------------------------------------------------------------
  /// 🟢 2) EXPORT XLSX (EXCEL)
  /// ------------------------------------------------------------------------
  static Future<String> exportXLSX(List<ConnectionModel> list, int page) async {
    final excel = Excel.createExcel();
    final sheet = excel['Connexions'];

    // header
    sheet.appendRow([
      "ID",
      "User ID",
      "Device ID",
      "IP",
      "Voucher",
      "User Agent",
      "Début",
      "Fin",
      "Succès",
      "Note"
    ]);

    // rows
    for (var c in list) {
      sheet.appendRow([
        c.id,
        c.userId,
        c.deviceId,
        c.ip,
        c.voucherCode ?? "",
        c.userAgent,
        c.startAt,
        c.endAt ?? "",
        c.success ? "Oui" : "Non",
        c.note ?? "",
      ]);
    }

    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final fileName = "connections_page${page}_$stamp.xlsx";

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(excel.encode()!);

    await Share.shareXFiles([XFile(file.path)], text: "Export Excel (XLSX)");
    return file.path;
  }

  /// ------------------------------------------------------------------------
  /// 🔴 3) EXPORT PDF (TABLE PRO)
  /// ------------------------------------------------------------------------
  static Future<String> exportPDF(List<ConnectionModel> list, int page) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final stamp = DateFormat('dd/MM/yyyy HH:mm').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        build: (context) {
          return [
            pw.Text(
              "BARRY WIFI — Export Connexions",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text("Page: $page"),
            pw.Text("Généré le : $stamp"),
            pw.SizedBox(height: 12),

            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              headers: [
                "ID",
                "IP",
                "User",
                "Device",
                "Voucher",
                "Début",
                "Fin",
                "OK",
              ],
              data: list.map((c) {
                return [
                  c.id,
                  c.ip,
                  c.userId,
                  c.deviceId,
                  c.voucherCode ?? "",
                  c.startAt,
                  c.endAt ?? "",
                  c.success ? "✔" : "✘",
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/connections_page${page}.pdf";
    final file = File(path);

    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: "Export PDF");
    return path;
  }
}
