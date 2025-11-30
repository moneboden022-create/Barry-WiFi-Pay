// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/auth_token.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final countryController = TextEditingController(text: "GN");
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    countryController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E81CE), Color(0xFFB088FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi, size: 60, color: Colors.blue),
                  const SizedBox(height: 10),
                  const Text(
                    "BARRY WI-FI",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Téléphone
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: "Téléphone",
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pays
                  TextField(
                    controller: countryController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.flag),
                      labelText: "Pays (ex : GN)",
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mot de passe
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: "Mot de passe",
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot');
                      },
                      child: const Text("Mot de passe oublié ?"),
                    ),
                  ),
                  const SizedBox(height: 8),

                  loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() => loading = true);

                              final ok = await AuthService.login(
                                phone: phoneController.text,
                                country: countryController.text,
                                password: passwordController.text,
                              );

                              setState(() => loading = false);

                              if (ok) {
                                // 👉 NE MET RIEN ICI POUR LE TOKEN
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Connexion échouée"),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: const Text("Se connecter"),
                          ),
                        ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text("Créer un compte"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
