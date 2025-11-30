// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // utilise themeNotifier déclaré dans main.dart
import 'package:barry_wifi/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDark = false;
  String selectedLang = 'fr';
  String firstName = '';
  String lastName = '';
  String phone = '';
  String country = '';

  @override
  void initState() {
    super.initState();
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('theme_dark') ?? false;
      selectedLang = prefs.getString('lang') ?? 'fr';
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      phone = prefs.getString('phone') ?? '';
      country = prefs.getString('country') ?? 'Guinée';
    });
  }

  Future<void> _saveTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark', value);
    themeNotifier.value = value;
    setState(() => isDark = value);
  }

  Future<void> _saveLang(String v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', v);
    setState(() => selectedLang = v);
    // TODO: apply localization change if you have i18n
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le lien")));
    }
  }

  Future<void> _openWhatsApp(String number) async {
    final url = 'https://wa.me/$number';
    await _openUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // LANGUAGE CARD
          _sectionTitle('Langue'),
          _card(
            child: Row(
              children: [
                const Icon(Icons.language, size: 26),
                const SizedBox(width: 12),
                const Text('Langue', style: TextStyle(fontSize: 16)),
                const Spacer(),
                DropdownButton<String>(
                  value: selectedLang,
                  items: const [
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (v) {
                    if (v != null) _saveLang(v);
                  },
                )
              ],
            ),
          ),

          const SizedBox(height: 14),

          // PROFILE SUMMARY CARD
          _sectionTitle('Modifier le profil'),
          _card(
            child: Column(
              children: [
                _infoRow(Icons.person, 'Prénom', firstName),
                const SizedBox(height: 6),
                _infoRow(Icons.person, 'Nom', lastName),
                const SizedBox(height: 6),
                _infoRow(Icons.phone, 'Téléphone', phone),
                const SizedBox(height: 6),
                _infoRow(Icons.flag, 'Pays', country),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Éditer le profil'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                      style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () {
                        // TODO: share app link logic
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partager (à implémenter)')));
                      },
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // PASSWORD CARD
          _sectionTitle('Changer mot de passe'),
          _card(
            child: Column(
              children: [
                _passwordField('Ancien mot de passe'),
                const SizedBox(height: 8),
                _passwordField('Nouveau mot de passe'),
                const SizedBox(height: 8),
                _passwordField('Confirmation'),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      // TODO: change password
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fonctionnalité en cours')));
                    },
                    child: const Text('Changer mot de passe'),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 14),

          // THEME CARD
          _sectionTitle('Apparence'),
          _card(
            child: SwitchListTile(
              title: const Text('Mode sombre'),
              secondary: const Icon(Icons.dark_mode),
              value: isDark,
              onChanged: (v) => _saveTheme(v),
            ),
          ),

          const SizedBox(height: 14),

          // ABOUT CARD
          _sectionTitle('À propos'),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Version 1.0.0'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _openWhatsApp('620035847'),
                  child: const Text('Aide / Support WhatsApp : 620035847', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, "/privacy"),
                  child: const Text('Politique de confidentialité', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Center(
            child: Text('Conçu par BARRY • © ${DateTime.now().year}', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.7))),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.04) : Colors.black45, blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(child: Text(value.isEmpty ? '-' : value)),
      ],
    );
  }

  Widget _passwordField(String label) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}
