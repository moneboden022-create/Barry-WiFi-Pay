import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final passwordController = TextEditingController();
  bool isBusiness = false;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: "Pays"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),

            SwitchListTile(
              title: const Text("Compte entreprise ?"),
              value: isBusiness,
              onChanged: (v) => setState(() => isBusiness = v),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);

                      final ok = await AuthService.register(
                        phoneController.text,
                        countryController.text,
                        passwordController.text,
                        isBusiness,
                      );

                      setState(() => loading = false);

                      if (ok) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Text("Créer le compte"),
                  ),
          ],
        ),
      ),
    );
  }
}
