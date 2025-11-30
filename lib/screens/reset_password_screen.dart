import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final phoneController = TextEditingController();
  final codeController = TextEditingController();
  final passController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réinitialiser mot de passe"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Téléphone",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: "Code reçu",
                prefixIcon: Icon(Icons.verified),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);

                      final ok = await AuthService.resetPassword(
                        phoneController.text,
                        codeController.text,
                        passController.text,
                      );

                      setState(() => loading = false);

                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Mot de passe réinitialisé !")),
                        );
                        Navigator.pushNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Impossible de réinitialiser le mot de passe.")),
                        );
                      }
                    },
                    child: const Text("Valider"),
                  ),
          ],
        ),
      ),
    );
  }
}
