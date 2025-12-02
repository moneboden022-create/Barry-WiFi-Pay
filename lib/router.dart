// lib/router.dart
// Router principal - BARRY WiFi 5G
import 'package:flutter/material.dart';

// Écrans principaux
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
import 'screens/settings_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/profile_screen.dart';

// Nouvelles pages 5G
import 'screens/about_screen.dart';
import 'screens/terms_screen.dart';

// Écrans Admin
import 'screens/admin_dashboard.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    // ========== ÉCRANS PUBLICS ==========
    '/splash': (_) => const SplashScreen(),
    '/language': (_) => const LanguageScreen(),
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
    '/home': (_) => const HomeScreen(),
    '/qrscan': (_) => const QRScannerScreen(),
    '/voucher': (_) => const VoucherScreen(),
    '/forgot': (_) => const ForgotPasswordScreen(),
    '/reset': (_) => const ResetPasswordScreen(),
    '/subscriptions': (_) => const SubscriptionsScreen(),
    '/wifi-control': (_) => const WifiControlScreen(),
    '/connections': (_) => const ConnectionsScreen(),
    '/settings': (_) => const SettingsScreen(),
    '/privacy': (_) => const PrivacyPolicyScreen(),
    '/profile': (_) => const ProfileScreen(),
    
    // ========== NOUVELLES PAGES 5G ==========
    '/about': (_) => const AboutScreen(),
    '/terms': (_) => const TermsScreen(),
    
    // ========== ÉCRANS ADMIN ==========
    '/admin': (_) => const AdminDashboardScreen(),  // Ancien (rétrocompat)
    '/admin/login': (_) => const AdminLoginScreen(),
    '/admin/dashboard': (_) => const AdminDashboardScreen(),
  };
}
