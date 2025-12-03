// lib/screens/settings/settings_screen.dart
// ⚙️ BARRY WI-FI - Paramètres Premium 5G

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _autoConnect = false;
  bool _saveData = false;
  String _language = 'Français';
  String _quality = 'Auto';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('theme_dark') ?? true;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _autoConnect = prefs.getBool('auto_connect') ?? false;
      _saveData = prefs.getBool('save_data') ?? false;
      _language = prefs.getString('language') ?? 'Français';
      _quality = prefs.getString('quality') ?? 'Auto';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildAppearanceSection(),
                      const SizedBox(height: 20),
                      _buildNotificationsSection(),
                      const SizedBox(height: 20),
                      _buildConnectionSection(),
                      const SizedBox(height: 20),
                      _buildAboutSection(),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppGradients.neonRainbow.createShader(bounds),
              child: Text(
                'Paramètres',
                style: AppTextStyles.h4.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'Apparence',
      icon: Icons.palette_outlined,
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Mode sombre',
          subtitle: 'Interface sombre pour réduire la fatigue oculaire',
          value: _isDarkMode,
          onChanged: (value) {
            setState(() => _isDarkMode = value);
            _saveSetting('theme_dark', value);
            themeNotifier.value = value;
          },
        ),
        const Divider(color: AppColors.darkBorder, height: 1),
        _buildSelectTile(
          icon: Icons.language,
          title: 'Langue',
          value: _language,
          options: ['Français', 'English', 'العربية'],
          onChanged: (value) {
            setState(() => _language = value);
            _saveSetting('language', value);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active_outlined,
          title: 'Notifications push',
          subtitle: 'Recevoir des alertes importantes',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            _saveSetting('notifications', value);
          },
        ),
      ],
    );
  }

  Widget _buildConnectionSection() {
    return _buildSection(
      title: 'Connexion',
      icon: Icons.wifi,
      children: [
        _buildSwitchTile(
          icon: Icons.autorenew,
          title: 'Connexion automatique',
          subtitle: 'Se connecter automatiquement au Wi-Fi BARRY',
          value: _autoConnect,
          onChanged: (value) {
            setState(() => _autoConnect = value);
            _saveSetting('auto_connect', value);
          },
        ),
        const Divider(color: AppColors.darkBorder, height: 1),
        _buildSwitchTile(
          icon: Icons.data_saver_on_outlined,
          title: 'Économie de données',
          subtitle: 'Réduire la consommation de données',
          value: _saveData,
          onChanged: (value) {
            setState(() => _saveData = value);
            _saveSetting('save_data', value);
          },
        ),
        const Divider(color: AppColors.darkBorder, height: 1),
        _buildSelectTile(
          icon: Icons.speed,
          title: 'Qualité de connexion',
          value: _quality,
          options: ['Auto', 'Haute', 'Moyenne', 'Basse'],
          onChanged: (value) {
            setState(() => _quality = value);
            _saveSetting('quality', value);
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'À propos',
      icon: Icons.info_outline,
      children: [
        _buildNavigationTile(
          icon: Icons.article_outlined,
          title: 'Conditions d\'utilisation',
          onTap: () => Navigator.pushNamed(context, '/terms'),
        ),
        const Divider(color: AppColors.darkBorder, height: 1),
        _buildNavigationTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Politique de confidentialité',
          onTap: () => Navigator.pushNamed(context, '/privacy'),
        ),
        const Divider(color: AppColors.darkBorder, height: 1),
        _buildNavigationTile(
          icon: Icons.help_outline,
          title: 'Aide & Support',
          onTap: () => Navigator.pushNamed(context, '/about'),
        ),
        const Divider(color: AppColors.darkBorder, height: 1),
        _buildInfoTile(
          icon: Icons.phone_android,
          title: 'Version de l\'app',
          value: '2.0.0 (5G Premium)',
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.neonViolet, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.neonViolet,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.neonViolet, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _buildSwitch(value, onChanged),
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: value ? AppGradients.neonVioletGradient : null,
          color: value ? null : AppColors.darkBorder,
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.neonViolet.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.neonViolet, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showOptionsSheet(title, value, options, onChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.modernTurquoise,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.modernTurquoise,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neonViolet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.neonViolet, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.neonViolet, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h6.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            ...options.map((option) => ListTile(
                  onTap: () {
                    onChanged(option);
                    Navigator.pop(context);
                  },
                  leading: Radio<String>(
                    value: option,
                    groupValue: currentValue,
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: AppColors.neonViolet,
                  ),
                  title: Text(
                    option,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: option == currentValue
                          ? AppColors.neonViolet
                          : AppColors.textPrimary,
                    ),
                  ),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

