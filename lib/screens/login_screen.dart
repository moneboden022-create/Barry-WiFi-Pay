import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final countryController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
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
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() => loading = true);

                      final ok = await AuthService.login(
                        phoneController.text,
                        countryController.text,
                        passwordController.text,
                      );

                      setState(() => loading = false);

                      if (ok) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: const Text("Se connecter"),
                  ),

            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/register'),
              child: const Text("Créer un compte"),
            ),
          ],
        ),
      ),
    );
  }
}
