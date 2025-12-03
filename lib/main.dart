// lib/main.dart
// 🚀 BARRY WI-FI - Application Premium 5ème Génération

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';

// 🔥 NOTIFIER GLOBAL POUR LE THÈME
final ValueNotifier<bool> themeNotifier = ValueNotifier<bool>(true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration du status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Mode immersif
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // Charger le thème enregistré
  final prefs = await SharedPreferences.getInstance();
  themeNotifier.value = prefs.getBool('theme_dark') ?? true;

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

          // 🌗 THÈME PREMIUM 5G
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Écran de démarrage
          initialRoute: "/splash",

          // 🛣️ Routes avec transitions fluides
          onGenerateRoute: AppRouter.onGenerateRoute,

          // Builder pour overlay global
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
