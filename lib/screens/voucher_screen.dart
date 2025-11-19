import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoucherScreen extends StatefulWidget {
  final String? scannedCode;

  const VoucherScreen({super.key, this.scannedCode});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    // Si un code a été scanné, on le met dans le champ
    if (widget.scannedCode != null) {
      codeController.text = widget.scannedCode!;
    }
  }

  Future<void> useVoucher() async {
    setState(() {
      loading = true;
      message = "";
    });

    // 🔁 Remplace par l’URL de ton backend
    final url = Uri.parse("https://TON-SERVEUR/voucher/use");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // 🔁 Plus tard : mettre le vrai token utilisateur
          "Authorization": "Bearer TON_TOKEN",
        },
        body: jsonEncode({"code": codeController.text}),
      );

      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        setState(() {
          message = "Voucher accepté ✔ Connexion activée";
        });
      } else {
        setState(() {
          message = "Erreur : ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        message = "Erreur réseau : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activer avec Voucher"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Entrer le code du voucher ou scanner un QR code",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Champ de texte
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Code voucher",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton vérifier
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: useVoucher,
                    child: const Text("Activer le Wi-Fi"),
                  ),
            const SizedBox(height: 20),

            // Bouton SCANNER
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, "/qrscan");
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scanner QR Code"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // Message retour
            Text(
              message,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
