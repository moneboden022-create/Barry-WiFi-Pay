import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Politique de confidentialité",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              "🔒 Politique de confidentialité",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Votre confidentialité est très importante pour nous. "
              "Dans le cadre du service BARRY WI-FI, nous collectons uniquement les informations "
              "strictement nécessaires au fonctionnement du service : numéro de téléphone, pays, "
              "identifiants de connexion et historique des connexions.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              "Nous ne vendons jamais vos données et elles ne sont "
              "partagées avec aucun tiers.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              "Les paiements (Orange Money, MTN Money, etc.) sont sécurisés "
              "et ne passent jamais directement par nos serveurs.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Pour toute question ou suppression de données, contactez-nous au : "
              "WhatsApp +224 620035847.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
