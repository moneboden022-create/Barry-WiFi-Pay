// 🛣️ BARRY WI-FI 5G – Router Premium avec transitions animées

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';

// ========== AUTH & SPLASH ==========
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';

// ========== SCREENS PRINCIPAUX ==========
import 'screens/home/home_screen.dart';
import 'screens/wifi/wifi_control_screen.dart';
import 'screens/vouchers/voucher_screen.dart';
import 'screens/subscriptions/subscriptions_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/qr_scanner/qr_scanner_screen.dart';

// ========== USER ==========
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';

// ========== LÉGAL ==========
import 'screens/legal/about_screen.dart';
import 'screens/legal/terms_screen.dart';
import 'screens/legal/privacy_policy_screen.dart';

// ========== ADMIN ==========
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/admin/admin_voucher_manager_screen.dart';
import 'screens/admin/admin_devices_screen.dart';
import 'screens/admin/admin_connections_screen.dart';
import 'screens/admin/admin_stats_screen.dart';
import 'screens/admin/admin_zones_screen.dart';
import 'screens/admin/voucher_generator_screen.dart';
import 'screens/admin/admin_sessions_screen.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // ======== SPLASH =========
      case '/':
      case '/splash':
        return _fade(const SplashScreen(), settings);

      // ======== AUTH =========
      case '/login':
        return _slide(const LoginScreen(), settings);

      case '/register':
        return _slide(const RegisterScreen(), settings);

      case '/forgot':
        return _slide(const ForgotPasswordScreen(), settings);

      case '/reset':
        return _slide(const ResetPasswordScreen(), settings);

      // ======== PRINCIPAL =========
      case '/home':
        return _fade(const HomeScreen(), settings);

      case '/wifi':
        return _slideUp(const WifiControlScreen(), settings);

      case '/voucher':
        return _slide(
          VoucherScreen(scannedCode: args as String?),
          settings,
        );

      case '/subscriptions':
        return _slide(const SubscriptionsScreen(), settings);

      case '/history':
        return _slide(const HistoryScreen(), settings);

      case '/qrscan':
        return _slideUp(const QRScannerScreen(), settings);

      // ======== UTILISATEUR =========
      case '/profile':
        return _slide(const ProfileScreen(), settings);

      case '/settings':
        return _slide(const SettingsScreen(), settings);

      // ======== LÉGAL =========
      case '/about':
        return _slide(const AboutScreen(), settings);

      case '/terms':
        return _slide(const TermsScreen(), settings);

      case '/privacy':
        return _slide(const PrivacyPolicyScreen(), settings);

      // ======== ADMIN =========
      case '/admin/login':
        return _fade(const AdminLoginScreen(), settings);

      case '/admin':
      case '/admin/dashboard':
        return _adminRoute(const AdminDashboardScreen(), settings);

      case '/admin/sessions':
        return _adminRoute(const AdminSessionsScreen(), settings);

      case '/admin/users':
        return _adminRoute(const AdminUsersScreen(), settings);

      case '/admin/vouchers':
        return _adminRoute(const AdminVoucherManagerScreen(), settings);

      case '/admin/devices':
        return _adminRoute(const AdminDevicesScreen(), settings);

      case '/admin/connections':
        return _adminRoute(const AdminConnectionsScreen(), settings);

      case '/admin/stats':
        return _adminRoute(const AdminStatsScreen(), settings);

      case '/admin/zones':
        return _adminRoute(const AdminZonesScreen(), settings);

      // 🎟️ Génération massive de vouchers
      case '/admin/voucher-generator':
        return _adminRoute(const VoucherGeneratorScreen(), settings);

      // ======== DEFAULT =========
      default:
        return _fade(const SplashScreen(), settings);
    }
  }

  // 🔵 Transition Fade
  static PageRouteBuilder _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: page,
      ),
    );
  }

  // 🔵 Slide horizontal + Fade
  static PageRouteBuilder _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, animation, __) => SlideTransition(
        position: Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(curve: Curves.easeOutCubic, parent: animation)),
        child: FadeTransition(
          opacity: animation,
          child: page,
        ),
      ),
    );
  }

  // 🔵 Slide vertical (Modal style)
  static PageRouteBuilder _slideUp(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, animation, __) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(curve: Curves.easeOutCubic, parent: animation)),
        child: page,
      ),
    );
  }

  // 🔐 Route admin avec vérification
  static PageRouteBuilder _adminRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, __) {
        // Vérifier si admin de manière synchrone
        return FutureBuilder<bool>(
          future: _checkAdminAccess(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.data == true) {
              return FadeTransition(opacity: animation, child: page);
            } else {
              // Rediriger vers /home si pas admin
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/home');
              });
              return const Scaffold(
                body: Center(child: Text('Accès refusé')),
              );
            }
          },
        );
      },
    );
  }

  // Vérifier si l'utilisateur est admin
  static Future<bool> _checkAdminAccess() async {
    return await AuthService.isAdmin();
  }

}
