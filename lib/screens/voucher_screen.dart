// lib/screens/voucher_screen.dart
import 'package:flutter/material.dart';
import '../data/plans.dart';
import '../services/voucher_service.dart';

class VoucherScreen extends StatefulWidget {
  final String? scannedCode;
  final WifiPlan? customPlan;

  const VoucherScreen({
    super.key,
    this.scannedCode,
    this.customPlan,
  });

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
    if (widget.scannedCode != null) {
      codeController.text = widget.scannedCode!;
    }
  }

  Future<void> useVoucher() async {
    final code = codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      loading = true;
      message = "";
    });

    // --- APPEL API CORRIGÉ ICI ---
    final result = await VoucherService.useVoucher(code);

    setState(() {
      loading = false;
      message = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.customPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Activer avec Voucher"),
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4DA3FF), Color(0xFFB088FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan != null) ...[
                    const Text(
                      "Forfait sélectionné",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(plan.name),
                    Text("${plan.price} GNF"),
                    Text("Durée : ${plan.durationMinutes} minutes"),
                    const Divider(height: 24),
                  ],

                  const Text(
                    "Entrer le code du voucher",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // INPUT CODE
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.key),
                      labelText: "Code voucher",
                    ),
                  ),

                  const SizedBox(height: 20),

                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: useVoucher,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007BFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                            ),
                            child: const Text(
                              "Activer le Wi-Fi",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                  const SizedBox(height: 16),

                  if (message.isNotEmpty)
                    Text(
                      message,
                      style: TextStyle(
                        color: message.startsWith("Erreur")
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
