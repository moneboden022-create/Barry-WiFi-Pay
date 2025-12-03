// lib/core/theme/app_gradients.dart
// 🎨 BARRY WI-FI - Dégradés Premium 5ème Génération

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // 🔥 Dégradé principal premium (Admin Style)
  static const LinearGradient primaryPremium = LinearGradient(
    colors: [
      AppColors.deepBlue,
      AppColors.electricBlue,
      AppColors.neonViolet,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌌 Dégradé de fond principal
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      AppColors.deepBlue,
      AppColors.darkBackground,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 💜 Dégradé violet néon
  static const LinearGradient neonVioletGradient = LinearGradient(
    colors: [
      AppColors.neonViolet,
      AppColors.cyberPurple,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔵 Dégradé bleu électrique
  static const LinearGradient electricBlueGradient = LinearGradient(
    colors: [
      AppColors.electricBlue,
      AppColors.modernTurquoise,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌊 Dégradé turquoise
  static const LinearGradient turquoiseGradient = LinearGradient(
    colors: [
      Color(0xFF00B4DB),
      Color(0xFF0083B0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🟢 Dégradé succès
  static const LinearGradient successGradient = LinearGradient(
    colors: [
      Color(0xFF00B09B),
      Color(0xFF96C93D),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🟠 Dégradé warning
  static const LinearGradient warningGradient = LinearGradient(
    colors: [
      Color(0xFFFF8008),
      Color(0xFFFFC837),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔴 Dégradé erreur
  static const LinearGradient errorGradient = LinearGradient(
    colors: [
      Color(0xFFFF416C),
      Color(0xFFFF4B2B),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌙 Dégradé sombre premium
  static const LinearGradient darkPremium = LinearGradient(
    colors: [
      Color(0xFF0F0C29),
      Color(0xFF302B63),
      Color(0xFF24243E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔮 Dégradé cyber
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🌈 Dégradé arc-en-ciel néon
  static const LinearGradient neonRainbow = LinearGradient(
    colors: [
      Color(0xFF00C4FF),
      Color(0xFF6C4DFF),
      Color(0xFFFF006E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ❄️ Dégradé glassmorphism
  static LinearGradient glassGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🎭 Dégradé carte premium
  static const LinearGradient cardPremium = LinearGradient(
    colors: [
      Color(0xFF1B263B),
      Color(0xFF0D1B2A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ⚡ Dégradé splash screen
  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF0A1A3A),
      Color(0xFF1E3FAF),
      Color(0xFF6C4DFF),
      Color(0xFF9D4EDD),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  // 🌟 Dégradé bouton primaire
  static const LinearGradient buttonPrimary = LinearGradient(
    colors: [
      AppColors.neonViolet,
      AppColors.electricBlue,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 🔘 Dégradé radial pour glow
  static RadialGradient neonGlow(Color color) {
    return RadialGradient(
      colors: [
        color.withOpacity(0.6),
        color.withOpacity(0.3),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}

