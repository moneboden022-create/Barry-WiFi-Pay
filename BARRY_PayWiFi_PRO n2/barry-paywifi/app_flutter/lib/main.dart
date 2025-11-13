import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// Adresse de base de l'API backend FastAPI.
/// - Sur **émulateur Android** : utilisez `http://10.0.2.2:8000`
/// - Sur **appareil réel** : mettez l'IP locale de votre PC, ex: `http://192.168.1.10:8000`
const String kApiBaseUrl = 'http://10.0.2.2:8000';

void main() {
  runApp(const PayWifiApp());
}

class PayWifiApp extends StatelessWidget {
  const PayWifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BARRY Pay‑WiFi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        fontFamily: 'Roboto',
      ),
      home: const PayWifiHomePage(),
    );
  }
}

class PayWifiHomePage extends StatelessWidget {
  const PayWifiHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4F46E5),
              Color(0xFFEC4899),
              Color(0xFFFACC15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 24),
                Text(
                  "Achetez votre connexion Wi‑Fi BARRY en quelques secondes.\n"
                  "Payez par Orange Money, MTN Money, PayPal ou Visa (intégrations prêtes).",
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                              color: Colors.black.withOpacity(0.25),
                            ),
                          ],
                        ),
                        child: const _PlansList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _SupportFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BARRY Pay‑WiFi",
              style: theme.textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Connexion illimitée. Design professionnel.",
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          tooltip: "Site web BARRY",
          onPressed: () async {
            final uri = Uri.parse('https://example.com'); // à personnaliser
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Impossible d'ouvrir le site.")),
              );
            }
          },
        ),
      ],
    );
  }
}

class _PlansList extends StatelessWidget {
  const _PlansList();

  List<WifiPlan> _plans() {
    return const [
      WifiPlan(
        id: 'day',
        name: 'Pass Jour',
        description: 'Idéal pour une journée de travail intensif ou de streaming.',
        priceLabel: '10 000 GNF',
        durationLabel: '24 heures',
        highlight: false,
      ),
      WifiPlan(
        id: 'month',
        name: 'Pass Mois',
        description: 'Parfait pour la maison, les boutiques et les petits bureaux.',
        priceLabel: '150 000 GNF',
        durationLabel: '30 jours',
        highlight: true,
      ),
      WifiPlan(
        id: 'year',
        name: 'Pass Année',
        description: 'Solution premium pour les entreprises et cyber‑cafés.',
        priceLabel: '1 500 000 GNF',
        durationLabel: '12 mois',
        highlight: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final plans = _plans();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final plan = plans[index];
        return _PlanCard(plan: plan);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: plans.length,
    );
  }
}

class WifiPlan {
  final String id;
  final String name;
  final String description;
  final String priceLabel;
  final String durationLabel;
  final bool highlight;

  const WifiPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.priceLabel,
    required this.durationLabel,
    this.highlight = false,
  });
}

class _PlanCard extends StatelessWidget {
  final WifiPlan plan;

  const _PlanCard({required this.plan});

  IconData _iconForPlan() {
    switch (plan.id) {
      case 'day':
        return Icons.flash_on;
      case 'month':
        return Icons.calendar_view_month;
      case 'year':
        return Icons.workspace_premium;
      default:
        return Icons.wifi;
    }
  }

  Future<void> _buyPlan(BuildContext context) async {
    final theme = Theme.of(context);
    try {
      final uri = Uri.parse('$kApiBaseUrl/payments/create');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': plan.id == 'day'
              ? 10000
              : plan.id == 'month'
                  ? 150000
                  : 1500000,
          'currency': 'GNF',
          'plan_id': plan.id,
          'method': 'mock', // à remplacer par "orange", "mtn", "paypal" ou "visa"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final paymentId = data['payment_id'] ?? 'N/A';
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Paiement créé'),
              content: Text(
                'Identifiant de paiement : $paymentId\n\n'
                'En mode MOCK, le paiement est simulé.\n'
                'Intégrez vos vraies passerelles Orange / MTN / PayPal / Visa côté backend.',
                style: theme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erreur lors de la création du paiement (${response.statusCode}).",
            ),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible de contacter l'API : $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = plan.highlight
        ? Colors.white.withOpacity(0.92)
        : Colors.white.withOpacity(0.86);
    final iconColor = plan.highlight ? const Color(0xFF4F46E5) : const Color(0xFF0F172A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.highlight
              ? const Color(0xFF4F46E5).withOpacity(0.50)
              : Colors.white.withOpacity(0.7),
          width: plan.highlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: plan.highlight ? 20 : 12,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _buyPlan(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.08),
                ),
                child: Icon(
                  _iconForPlan(),
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.description,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(
                          plan.durationLabel,
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan.priceLabel,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton.icon(
                    onPressed: () => _buyPlan(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                    label: const Text(
                      "Acheter",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportFooter extends StatelessWidget {
  const _SupportFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Support BARRY Pay‑WiFi",
          style: theme.textTheme.bodySmall!
              .copyWith(color: Colors.white.withOpacity(0.88)),
        ),
        TextButton.icon(
          onPressed: () async {
            final uri = Uri.parse('https://wa.me/0000000000'); // numéro WhatsApp à personnaliser
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Impossible d'ouvrir WhatsApp.")),
              );
            }
          },
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
          label: const Text(
            "WhatsApp",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
