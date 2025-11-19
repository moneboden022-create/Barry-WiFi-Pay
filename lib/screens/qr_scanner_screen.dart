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
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;

            if (code != null && code.isNotEmpty) {
              // On ferme l'écran du scanner
              Navigator.pop(context);

              // On ouvre l'écran Voucher avec le code scanné
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoucherScreen(
                    scannedCode: code,
                  ),
                ),
              );
              break;
            }
          }
        },
      ),
    );
  }
}
