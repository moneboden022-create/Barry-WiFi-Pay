// lib/screens/about_screen.dart
// Page À propos professionnelle - BARRY WiFi
// Fondateur: Mamadou Mourtada Barry (MÖNÈBO DEN) - Siguiri, Guinée

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF0D1B2A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "À Propos",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              // Contenu
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Logo animé
                    _buildLogo(),
                    const SizedBox(height: 30),

                    // Nom de l'application
                    const Center(
                      child: Text(
                        "BARRY WI-FI",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                        ),
                        child: const Text(
                          "Version 5.0.0 - 5ᵉ Génération",
                          style: TextStyle(color: Colors.cyan, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "Système de gestion WiFi professionnel par vouchers",
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Section Fondateur
                    _sectionTitle("👤 Fondateur & PDG"),
                    _founderCard(),

                    const SizedBox(height: 30),

                    // Section Mission
                    _sectionTitle("🎯 Notre Mission"),
                    _missionCard(),

                    const SizedBox(height: 30),

                    // Section Fonctionnalités
                    _sectionTitle("✨ Fonctionnalités"),
                    _featuresCard(),

                    const SizedBox(height: 30),

                    // Section Contact
                    _sectionTitle("📞 Contact"),
                    _contactCard(context),

                    const SizedBox(height: 30),

                    // Section Technique
                    _sectionTitle("🛠️ Technologies"),
                    _techCard(),

                    const SizedBox(height: 40),

                    // Copyright
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "© ${DateTime.now().year} BARRY WiFi Technologies",
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Tous droits réservés",
                            style: TextStyle(color: Colors.white24, fontSize: 10),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Made with ❤️ in Siguiri, Guinea",
                            style: TextStyle(color: Colors.cyan, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 15,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.cyan.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.cyan, width: 3),
          ),
          child: const Center(
            child: Icon(
              Icons.wifi,
              size: 70,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _founderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade900.withOpacity(0.5), Colors.blue.shade900.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyan, width: 2),
                  color: const Color(0xFF1B263B),
                ),
                child: const Center(
                  child: Text(
                    "MB",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mamadou Mourtada Barry",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "MÖNÈBO DEN",
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white54, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "Siguiri, Guinée",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Entrepreneur et développeur passionné, créateur de solutions technologiques innovantes pour améliorer la connectivité en Afrique de l'Ouest. BARRY WiFi représente ma vision d'un accès Internet accessible, sécurisé et professionnel pour tous.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BARRY WI-FI est une solution innovante de gestion d'accès WiFi par système de vouchers, conçue pour offrir une connectivité fiable et sécurisée.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Notre plateforme permet :",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _MissionPoint(text: "Un contrôle complet des accès WiFi"),
          _MissionPoint(text: "Une gestion multi-appareils intelligente"),
          _MissionPoint(text: "Un suivi en temps réel des connexions"),
          _MissionPoint(text: "Un système de vouchers sécurisé"),
          _MissionPoint(text: "Des statistiques détaillées"),
        ],
      ),
    );
  }

  Widget _featuresCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _featureChip("🔐 Auth JWT", Colors.blue),
          _featureChip("🎟️ Vouchers", Colors.orange),
          _featureChip("📊 Dashboard", Colors.purple),
          _featureChip("📱 Multi-devices", Colors.green),
          _featureChip("🌍 Géolocalisation", Colors.teal),
          _featureChip("🛡️ Sécurité", Colors.red),
          _featureChip("📈 Statistiques", Colors.cyan),
          _featureChip("🏢 Entreprise", Colors.indigo),
        ],
      ),
    );
  }

  Widget _featureChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _contactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _contactItem(
            Icons.phone,
            "+224 620 03 58 47",
            Colors.green,
            () => _launchUrl("tel:+224620035847"),
          ),
          const SizedBox(height: 12),
          _contactItem(
            Icons.message,
            "WhatsApp",
            Colors.green,
            () => _launchUrl("https://wa.me/224620035847"),
          ),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _techCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TechItem(icon: "📱", label: "Flutter", sublabel: "Mobile & Web"),
              SizedBox(width: 20),
              _TechItem(icon: "⚡", label: "FastAPI", sublabel: "Backend"),
              SizedBox(width: 20),
              _TechItem(icon: "🗄️", label: "SQLite", sublabel: "Database"),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _MissionPoint extends StatelessWidget {
  final String text;
  const _MissionPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.cyan, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  final String icon;
  final String label;
  final String sublabel;

  const _TechItem({required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(sublabel, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

