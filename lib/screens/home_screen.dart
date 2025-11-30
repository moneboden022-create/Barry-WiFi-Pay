// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/plans.dart';
import 'voucher_screen.dart';
import 'qr_scanner_screen.dart';
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _customAmountController = TextEditingController();
  int? customMinutes;

  void calculateCustomPlan() {
    final text = _customAmountController.text;

    if (text.isEmpty) {
      setState(() {
        customMinutes = null;
      });
      return;
    }

    final amount = int.tryParse(text);
    if (amount == null || amount < 500) {
      setState(() {
        customMinutes = null;
      });
      return;
    }

    final plan = CustomWifiPlan(amount);
    setState(() {
      customMinutes = plan.durationMinutes;
    });
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  backgroundColor: const Color(0xFFEAE0FF),
  appBar: AppBar(
    backgroundColor: const Color(0xFF007BFF),
    title: const Text(
      "BARRY WI-FI",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
  ),

  drawer: const AppDrawer(),   // <<< AJOUT IMPORTANT

  body: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // -------------------------
            // MONTANT PERSONNALISÉ
            // -------------------------
            const Text(
              "Montant personnalisé",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tapez un montant (min : 500 GNF)",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => calculateCustomPlan(),
                    decoration: InputDecoration(
                      hintText: "Ex : 5000",
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (customMinutes != null) ...[
                    Text(
                      "Durée générée : $customMinutes minutes",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final amount =
                            int.parse(_customAmountController.text);
                        final plan = CustomWifiPlan(amount);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VoucherScreen(
                              scannedCode: "custom",
                              customPlan: plan,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        "Acheter",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // FORFAITS INDIVIDUELS
            // -------------------------
            const Text(
              "Forfaits Individuels",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: userPlans.map((plan) {
                return _buildPlanCard(plan);
              }).toList(),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // FORFAITS ENTREPRISE
            // -------------------------
            const Text(
              "Forfaits Entreprises",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: businessPlans.map((plan) {
                return _buildPlanCard(plan);
              }).toList(),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // ACTIVATION DIRECTE PAR VOUCHER
            // -------------------------
            const Text(
              "Activation directe par voucher",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QRScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text("Scanner un QR code"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VoucherScreen(
                              scannedCode: null,
                              customPlan: null,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.key),
                      label: const Text("Saisir un code voucher"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET CARTE FORFAIT
  Widget _buildPlanCard(WifiPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(plan.description),
          const SizedBox(height: 5),
          Text(
            "${plan.price} GNF",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoucherScreen(
                    scannedCode: "manual_${plan.id}",
                    customPlan: plan,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: const Icon(Icons.shopping_cart),
            label: const Text("Acheter"),
          ),
        ],
      ),
    );
  }
}
