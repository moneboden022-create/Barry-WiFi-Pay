// lib/widgets/language_selector.dart
import 'package:flutter/material.dart';
import '../services/auth_storage.dart';

class LanguageSelector extends StatefulWidget {
  final void Function(String code)? onChanged;
  const LanguageSelector({super.key, this.onChanged});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _locale = 'fr';

  @override
  void initState() {
    super.initState();
    AuthStorage.loadLocale().then((v) {
      if (v != null) setState(() => _locale = v);
    });
  }

  void _setLocale(String code) {
    setState(() => _locale = code);
    AuthStorage.saveLocale(code);
    widget.onChanged?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.language),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: _locale,
          items: const [
            DropdownMenuItem(value: 'fr', child: Text('Français')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (v) {
            if (v != null) _setLocale(v);
          },
        ),
      ],
    );
  }
}
