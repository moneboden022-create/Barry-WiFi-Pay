// lib/widgets/theme_switch.dart
import 'package:flutter/material.dart';
import '../services/auth_storage.dart';

class ThemeSwitch extends StatefulWidget {
  final void Function(bool isDark)? onChanged;
  const ThemeSwitch({super.key, this.onChanged});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    AuthStorage.loadDarkMode().then((v) {
      setState(() => _isDark = v);
    });
  }

  void _toggle(bool v) {
    setState(() => _isDark = v);
    AuthStorage.saveDarkMode(v);
    widget.onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.brightness_6),
        const SizedBox(width: 8),
        Switch(
          value: _isDark,
          onChanged: _toggle,
        ),
      ],
    );
  }
}
