// lib/services/auth_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyThemeDark = 'theme_dark';
  static const String _keyLocale = 'locale_code';

  // Token
  static Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyToken, token);
  }

  static Future<String?> loadToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyToken);
  }

  static Future<void> removeToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_keyToken);
  }

  // Theme
  static Future<void> saveDarkMode(bool dark) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keyThemeDark, dark);
  }

  static Future<bool> loadDarkMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keyThemeDark) ?? true; // default dark
  }

  // Locale
  static Future<void> saveLocale(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_keyLocale, code);
  }

  static Future<String?> loadLocale() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_keyLocale);
  }
}
