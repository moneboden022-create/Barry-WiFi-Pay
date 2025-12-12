// lib/core/widgets/app_drawer.dart
// 🎛️ BARRY WI-FI - Navigation Drawer Premium 5G

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import 'animated_logo.dart';

class AppDrawer extends StatefulWidget {
  final String? currentRoute;

  const AppDrawer({super.key, this.currentRoute});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String? _avatarPath;
  String _userName = "Utilisateur";
  String _userEmail = "";

  final List<_DrawerMenuItem> _menuItems = [
    _DrawerMenuItem(
      icon: Icons.home_rounded,
      title: "Accueil",
      route: "/home",
    ),
    _DrawerMenuItem(
      icon: Icons.history_rounded,
      title: "Historique",
      route: "/connections",
    ),
    _DrawerMenuItem(
      icon: Icons.wifi_tethering_rounded,
      title: "Activer Wi-Fi",
      route: "/wifi-control",
    ),
    _DrawerMenuItem(
      icon: Icons.card_membership_rounded,
      title: "Abonnements",
      route: "/subscriptions",
    ),
    _DrawerMenuItem(
      icon: Icons.confirmation_number_rounded,
      title: "Vouchers",
      route: "/voucher",
    ),
    _DrawerMenuItem(
      icon: Icons.qr_code_scanner_rounded,
      title: "Scanner QR",
      route: "/qrscan",
    ),
  ];

  final List<_DrawerMenuItem> _settingsItems = [
    _DrawerMenuItem(
      icon: Icons.person_rounded,
      title: "Mon Profil",
      route: "/profile",
    ),
    _DrawerMenuItem(
      icon: Icons.settings_rounded,
      title: "Paramètres",
      route: "/settings",
    ),
    _DrawerMenuItem(
      icon: Icons.admin_panel_settings_rounded,
      title: "Admin Panel",
      route: "/admin",
      isAdmin: true,
    ),
  ];

  final List<_DrawerMenuItem> _legalItems = [
    _DrawerMenuItem(
      icon: Icons.info_rounded,
      title: "À Propos",
      route: "/about",
    ),
    _DrawerMenuItem(
      icon: Icons.gavel_rounded,
      title: "Conditions",
      route: "/terms",
    ),
    _DrawerMenuItem(
      icon: Icons.privacy_tip_rounded,
      title: "Confidentialité",
      route: "/privacy",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString("avatar_path");
      _userName = prefs.getString("user_name") ?? "Utilisateur";
      _userEmail = prefs.getString("user_email") ?? "";
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.darkCard.withOpacity(0.95),
                  AppColors.darkBackground.withOpacity(0.98),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header avec profil
                  _buildHeader(),

                  // Menu principal
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        const SizedBox(height: 8),
                        _buildSection("MENU PRINCIPAL", _menuItems),
                        const SizedBox(height: 16),
                        _buildSection("PARAMÈTRES", _settingsItems),
                        const SizedBox(height: 16),
                        _buildSection("LÉGAL", _legalItems),
                        const SizedBox(height: 24),

                        // Bouton déconnexion
                        _buildLogoutButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryPremium,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Hero(
                tag: "user-avatar",
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.neonVioletGradient,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonViolet.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _avatarPath != null
                        ? Image.file(
                            File(_avatarPath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: AppTextStyles.h6.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_userEmail.isNotEmpty)
                      Text(
                        _userEmail,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.neonGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Connecté",
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_DrawerMenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 2,
            ),
          ),
        ),
        ...items.asMap().entries.map((entry) {
          return _buildMenuItem(entry.value, entry.key);
        }),
      ],
    );
  }

  Widget _buildMenuItem(_DrawerMenuItem item, int index) {
    final isActive = widget.currentRoute == item.route;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateTo(item.route),
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.neonViolet.withOpacity(0.2),
            highlightColor: AppColors.neonViolet.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          AppColors.neonViolet.withOpacity(0.2),
                          AppColors.neonViolet.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: isActive
                    ? Border.all(
                        color: AppColors.neonViolet.withOpacity(0.3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.neonViolet.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: isActive
                          ? AppColors.neonViolet
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (item.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "ADMIN",
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  if (isActive)
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.neonViolet,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonViolet.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.error.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.error.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  "Déconnexion",
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlowingLogo(size: 24),
              const SizedBox(width: 10),
              Text(
                "BARRY WI-FI",
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "v2.0 • 5G Premium",
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(String route) {
    Navigator.pop(context);
    if (widget.currentRoute != route) {
      Navigator.pushNamed(context, route);
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}

class _DrawerMenuItem {
  final IconData icon;
  final String title;
  final String route;
  final bool isAdmin;

  _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.route,
    this.isAdmin = false,
  });
}

