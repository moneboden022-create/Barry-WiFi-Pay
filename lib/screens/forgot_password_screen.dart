import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final phoneController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mot de passe oublié"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Entrez votre numéro de téléphone et vous recevrez un code.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Téléphone",
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 20),

            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);

                      final ok =
                          await AuthService.forgotPassword(phoneController.text);

                      setState(() => loading = false);

                      if (ok) {
                        Navigator.pushNamed(context, '/reset');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Erreur lors de l’envoi du code.")),
                        );
                      }
                    },
                    child: const Text("Envoyer le code"),
                  ),
          ],
        ),
      ),
    );
  }
}
