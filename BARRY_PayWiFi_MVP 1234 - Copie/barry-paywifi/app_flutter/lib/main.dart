
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const PayWifiApp());

class PayWifiApp extends StatelessWidget {
  const PayWifiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BARRY Pay‑WiFi',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _status = "Aucun achat";

  Future<void> _buy(String plan) async {
    setState(() => _status = "Paiement en cours...");
    await Future.delayed(const Duration(seconds: 1));
    // Mock succès immédiat
    setState(() => _status = "Paiement réussi ✅ — Activation en cours...");
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _status = "Accès activé 🎉 (démo)");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0EA5E9), Color(0xFF4F46E5), Color(0xFFEC4899)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.wifi, size: 40, color: Colors.white),
                    const SizedBox(width: 12),
                    Text("BARRY Pay‑WiFi",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Choisis ton forfait",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _PlanTile(name: "Pass Jour", price: "10 000 GNF", onTap: () => _buy("day")),
                        _PlanTile(name: "Pass Mois", price: "150 000 GNF", onTap: () => _buy("month")),
                        _PlanTile(name: "Pass Année", price: "1 500 000 GNF", onTap: () => _buy("year")),
                        const SizedBox(height: 8),
                        Text("Moyens de paiement : Orange, MTN, PayPal, Visa",
                          style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Statut",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(_status, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final uri = Uri.parse("https://example.com/docs");
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    child: const Text("Besoin d'aide ? Voir le guide"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String name;
  final String price;
  final VoidCallback onTap;
  const _PlanTile({required this.name, required this.price, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.shade100,
      ),
      child: ListTile(
        leading: const Icon(Icons.bolt),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(price),
        trailing: ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.shopping_cart_checkout),
          label: const Text("Acheter"),
        ),
      ),
    );
  }
}
