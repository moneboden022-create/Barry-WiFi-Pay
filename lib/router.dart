// lib/router.dart
import 'package:flutter/material.dart';

// Import des écrans
import 'screens/splash_screen.dart';
import 'screens/language_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/voucher_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/wifi_control_screen.dart';
import 'screens/connections_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/settings_screen.dart';
import 'package:barry_wifi/screens/privacy_policy_screen.dart';
import 'screens/profile_screen.dart';   // ← AJOUT obligatoire

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (_) => const SplashScreen(),
    '/language': (_) => const LanguageScreen(),
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/home': (_) => const HomeScreen(),
    '/qrscan': (_) => const QRScannerScreen(),
    '/voucher': (_) => const VoucherScreen(),
    '/forgot': (_) => const ForgotPasswordScreen(),
    '/reset': (_) => const ResetPasswordScreen(),
    '/subscriptions': (context) => const SubscriptionsScreen(),
    '/wifi-control': (context) => const WifiControlScreen(),
    '/connections': (_) => const ConnectionsScreen(),
    '/admin': (context) => const AdminDashboardScreen(),
    '/settings': (ctx) => const SettingsScreen(),
    '/privacy': (ctx) => const PrivacyPolicyScreen(),
    '/profile': (_) => const ProfileScreen(),
  };
}
