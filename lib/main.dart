// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router.dart';

// 🔥 NOTIFIER GLOBAL POUR LE THÈME
final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le thème enregistré
  final prefs = await SharedPreferences.getInstance();
  themeNotifier.value = prefs.getBool('theme_dark') ?? false;

  runApp(const BarryWifiApp());
}

class BarryWifiApp extends StatelessWidget {
  const BarryWifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'BARRY WI-FI',
          debugShowCheckedModeBanner: false,

          // 🌍 Localisation
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
          ],

          // 🌗 THÈME CLAIR / SOMBRE
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF111111),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // Écran de démarrage
          initialRoute: "/splash",

          // Toutes les routes
          routes: AppRouter.routes,
        );
      },
    );
  }
}
