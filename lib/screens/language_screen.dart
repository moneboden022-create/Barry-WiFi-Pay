// lib/screens/language_screen.dart
import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E81CE), Color(0xFFB08BFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.language, size: 80, color: Colors.white),
            const SizedBox(height: 30),

            const Text(
              "Choisir la langue",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            _langBtn(context, "Français 🇫🇷", "fr"),
            const SizedBox(height: 20),

            _langBtn(context, "English 🇺🇸", "en"),
            const SizedBox(height: 20),

            _langBtn(context, "Guinée 🇬🇳", "gn"),
            const SizedBox(height: 20),

            _langBtn(context, "Autre langue 🌍", "other"),
          ],
        ),
      ),
    );
  }

  // Bouton stylé
  Widget _langBtn(BuildContext context, String label, String code) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
