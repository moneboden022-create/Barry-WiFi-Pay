// lib/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'voucher_screen.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanner un Voucher"),
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;

                if (code != null && code.isNotEmpty) {
                  Navigator.pop(context); // fermer le scanner

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VoucherScreen(scannedCode: code),
                    ),
                  );
                  break;
                }
              }
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Place le QR code dans le cadre pour scanner",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
