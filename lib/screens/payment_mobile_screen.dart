import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class PaymentMobileScreen extends StatefulWidget {
  final String userId;
  final int amount;

  const PaymentMobileScreen({
    super.key,
    required this.userId,
    required this.amount,
  });

  @override
  State<PaymentMobileScreen> createState() => _PaymentMobileScreenState();
}

class _PaymentMobileScreenState extends State<PaymentMobileScreen> {
  String operator = "orange"; // default
  final TextEditingController phoneCtrl = TextEditingController();

  bool loading = false;

  void pay() async {
    if (phoneCtrl.text.isEmpty) return;

    setState(() => loading = true);

    final result = await PaymentService.payWithMobileMoney(
      phone: phoneCtrl.text.trim(),
      operator: operator,
      amount: widget.amount,
      userId: widget.userId,
    );

    setState(() => loading = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result["success"] ? "Paiement réussi" : "Erreur"),
        content: Text(result["message"]),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement Mobile Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Montant : ${widget.amount} GNF",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text("Choisir opérateur", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Row(
              children: [
                ChoiceChip(
                  label: const Text("Orange Money"),
                  selected: operator == "orange",
                  onSelected: (_) => setState(() => operator = "orange"),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("MTN Money"),
                  selected: operator == "mtn",
                  onSelected: (_) => setState(() => operator = "mtn"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : pay,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Payer maintenant"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
