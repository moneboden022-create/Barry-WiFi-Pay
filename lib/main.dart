import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/voucher_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/qr_scanner_screen.dart';

void main() {
  runApp(const BarryWifiApp());
}

class BarryWifiApp extends StatelessWidget {
  const BarryWifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BARRY WI-FI',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: 'Roboto',
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/voucher': (context) => const VoucherScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/qrscan': (context) => const QRScannerScreen(),
      },
    );
  }
}
