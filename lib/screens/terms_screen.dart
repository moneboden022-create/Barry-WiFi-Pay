// lib/screens/terms_screen.dart
// Conditions d'utilisation - BARRY WiFi
// Conforme aux normes légales

import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "Conditions d'utilisation",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // En-tête
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyan.shade900, Colors.blue.shade900],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.gavel, color: Colors.white, size: 40),
                          const SizedBox(height: 10),
                          const Text(
                            "CONDITIONS GÉNÉRALES D'UTILISATION",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Dernière mise à jour: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sections
                    _buildSection(
                      "1. Conditions Générales",
                      """En utilisant l'application BARRY WI-FI et ses services associés, vous acceptez les présentes conditions d'utilisation. Ces conditions constituent un accord juridiquement contraignant entre vous et BARRY WiFi Technologies.

Le service est fourni "tel quel" et peut être modifié à tout moment sans préavis. Nous nous réservons le droit de refuser l'accès au service à toute personne, pour quelque raison que ce soit.""",
                    ),

                    _buildSection(
                      "2. Politique d'Utilisation Acceptable",
                      """En tant qu'utilisateur du service BARRY WI-FI, vous vous engagez à :

• Ne pas utiliser le service pour des activités illégales
• Ne pas partager de contenu inapproprié, offensant ou illégal
• Respecter les autres utilisateurs du réseau
• Ne pas tenter de pirater, contourner ou compromettre le système
• Ne pas utiliser le service pour envoyer des spams ou du contenu malveillant
• Ne pas revendre ou redistribuer l'accès au service sans autorisation

Toute violation de ces règles peut entraîner la suspension immédiate de votre compte sans remboursement.""",
                    ),

                    _buildSection(
                      "3. Politique de Confidentialité",
                      """Nous collectons uniquement les données nécessaires au fonctionnement du service :

• Numéro de téléphone (identification)
• Identifiant d'appareil (gestion multi-appareils)
• Historique des connexions (facturation et support)
• Données de géolocalisation (opt-in uniquement)

ENGAGEMENT DE CONFIDENTIALITÉ :
• Vos données ne sont JAMAIS vendues à des tiers
• Vos données ne sont partagées qu'avec votre consentement explicite
• Vous pouvez demander la suppression de vos données à tout moment (droit à l'oubli)
• Les données sont stockées de manière sécurisée avec chiffrement""",
                    ),

                    _buildSection(
                      "4. Système de Vouchers",
                      """Les vouchers BARRY WI-FI sont soumis aux conditions suivantes :

VOUCHERS INDIVIDUELS :
• Usage unique, non transférable
• Valables pour un seul appareil
• Durée définie à l'achat

VOUCHERS BUSINESS/ENTREPRISE :
• Permettent plusieurs appareils selon le type
• Transférables au sein de l'organisation
• Gestion centralisée par l'administrateur

CONDITIONS GÉNÉRALES VOUCHERS :
• Les vouchers expirés ne peuvent pas être réclamés
• Aucun remboursement après activation
• Les vouchers perdus ou volés ne sont pas remplacés
• La revente de vouchers est interdite""",
                    ),

                    _buildSection(
                      "5. Respect des Lois",
                      """L'utilisateur s'engage à respecter :

• Les lois locales de la République de Guinée
• Les lois internationales applicables
• Les réglementations sur les télécommunications
• Les droits de propriété intellectuelle

BARRY WiFi coopère avec les autorités compétentes en cas d'activités illégales détectées sur le réseau. Toute violation peut entraîner :
• Suspension immédiate du compte
• Signalement aux autorités compétentes
• Poursuites judiciaires le cas échéant""",
                    ),

                    _buildSection(
                      "6. Responsabilités de l'Utilisateur",
                      """L'utilisateur est responsable de :

• Garder son mot de passe confidentiel
• Signaler toute activité suspecte sur son compte
• Ne pas partager ses identifiants de connexion
• Utiliser le service de manière responsable
• S'assurer que les appareils connectés sont sécurisés

BARRY WiFi n'est pas responsable des dommages causés par :
• La négligence de l'utilisateur
• L'utilisation de mots de passe faibles
• Le partage non autorisé des identifiants""",
                    ),

                    _buildSection(
                      "7. Sécurité",
                      """BARRY WiFi met en œuvre des mesures de sécurité avancées :

PROTECTION DES DONNÉES :
• Chiffrement des données en transit et au repos
• Tokens JWT sécurisés pour l'authentification
• Protection contre les injections SQL et XSS

PROTECTION DU COMPTE :
• Limitation du nombre d'appareils
• Détection des tentatives de bruteforce
• Verrouillage automatique après tentatives échouées
• Alertes de sécurité en temps réel

INFRASTRUCTURE :
• Rate limiting pour prévenir les abus
• Journalisation des accès
• Surveillance continue du réseau""",
                    ),

                    _buildSection(
                      "8. Limites Légales",
                      """AVERTISSEMENTS IMPORTANTS :

• BARRY WI-FI ne contrôle pas le contenu accessible via Internet
• Nous ne sommes pas responsables des sites tiers visités
• L'utilisateur accède au contenu Internet à ses propres risques
• Les parents sont responsables de l'utilisation par leurs enfants

LIMITATION DE RESPONSABILITÉ :
• BARRY WiFi ne garantit pas une disponibilité de service à 100%
• Nous ne sommes pas responsables des pertes de données
• Les interruptions de service peuvent survenir pour maintenance

FORCE MAJEURE :
• BARRY WiFi n'est pas responsable des interruptions dues à des événements hors de son contrôle (catastrophes naturelles, pannes électriques, etc.)""",
                    ),

                    _buildSection(
                      "9. Modifications",
                      """BARRY WiFi se réserve le droit de modifier ces conditions à tout moment. Les modifications entrent en vigueur dès leur publication.

L'utilisation continue du service après modification constitue une acceptation des nouvelles conditions.

Nous vous encourageons à consulter régulièrement cette page pour rester informé des mises à jour.""",
                    ),

                    _buildSection(
                      "10. Contact",
                      """Pour toute question concernant ces conditions :

📞 Téléphone: +224 620 03 58 47
💬 WhatsApp: +224 620 03 58 47
📍 Adresse: Siguiri, Guinée

BARRY WiFi Technologies
Fondateur: Mamadou Mourtada Barry (MÖNÈBO DEN)""",
                    ),

                    const SizedBox(height: 30),

                    // Acceptation
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 40),
                          const SizedBox(height: 10),
                          const Text(
                            "En utilisant BARRY WI-FI, vous confirmez avoir lu et accepté ces conditions d'utilisation.",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "J'ai compris et j'accepte",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Copyright
                    Center(
                      child: Text(
                        "© ${DateTime.now().year} BARRY WiFi Technologies - Tous droits réservés",
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: Colors.cyan,
        collapsedIconColor: Colors.white54,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

