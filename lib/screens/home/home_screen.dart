// lib/screens/home/home_screen.dart
// 🏠 BARRY WI-FI - Dashboard Client Premium 5G

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _fadeController;
  late AnimationController _pulseController;

  String _userName = "Utilisateur";
  bool _isWifiActive = false;
  String _currentPlan = "Aucun abonnement";
  String _dataUsed = "0 MB";
  String _dataRemaining = "0 MB";
  String _timeRemaining = "0h 0m";
  int _connectionQuality = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString("user_name") ?? "Utilisateur";
      _isWifiActive = prefs.getBool("wifi_active") ?? false;
    });
    // TODO: Charger les vraies données depuis l'API
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.darkBackground,
      drawer: const AppDrawer(currentRoute: '/home'),
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
                // Header
                SliverToBoxAdapter(
                  child: HomeHeader(
                    userName: _userName,
                    onAvatarTap: () => Navigator.pushNamed(context, '/profile'),
                    onNotificationTap: () {
                      // TODO: Notifications
                    },
                    notificationCount: 3,
                  ),
                ),

                // Contenu
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Carte Wi-Fi Status
                      _buildWifiStatusCard(),
                      const SizedBox(height: 20),

                      // Stats rapides
                      _buildQuickStats(),
                      const SizedBox(height: 20),

                      // Abonnement actuel
                      _buildSubscriptionCard(),
                      const SizedBox(height: 20),

                      // Actions rapides
                      _buildQuickActions(),
                      const SizedBox(height: 20),

                      // Forfaits populaires
                      _buildPopularPlans(),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Menu drawer button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        backgroundColor: AppColors.neonViolet,
        child: const Icon(Icons.menu_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildWifiStatusCard() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return GradientCard(
          gradient: _isWifiActive
              ? AppGradients.successGradient
              : LinearGradient(
                  colors: [
                    AppColors.darkCard,
                    AppColors.darkCard.withOpacity(0.8),
                  ],
                ),
          padding: const EdgeInsets.all(24),
          enableGlow: _isWifiActive,
          glowColor: AppColors.neonGreen,
          child: Column(
            children: [
              Row(
                children: [
                  // Indicateur status
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isWifiActive
                          ? Colors.white.withOpacity(0.2)
                          : AppColors.darkBorder,
                      boxShadow: _isWifiActive
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(
                                    0.2 + _pulseController.value * 0.1),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _isWifiActive ? Icons.wifi : Icons.wifi_off,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isWifiActive ? 'Wi-Fi Actif' : 'Wi-Fi Inactif',
                          style: AppTextStyles.h5.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isWifiActive
                                    ? AppColors.neonGreen
                                    : AppColors.error,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isWifiActive
                                            ? AppColors.neonGreen
                                            : AppColors.error)
                                        .withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isWifiActive
                                  ? 'Connecté • $_timeRemaining restant'
                                  : 'Non connecté',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bouton activation
              NeonButton(
                text: _isWifiActive ? 'GÉRER LA CONNEXION' : 'ACTIVER LE WI-FI',
                icon: _isWifiActive ? Icons.settings : Icons.power_settings_new,
                gradient: _isWifiActive
                    ? null
                    : AppGradients.neonVioletGradient,
                onPressed: () => Navigator.pushNamed(context, '/wifi-control'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.data_usage,
            title: 'Données',
            value: _dataUsed,
            subtitle: 'utilisées',
            color: AppColors.modernTurquoise,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_outlined,
            title: 'Temps',
            value: _timeRemaining,
            subtitle: 'restant',
            color: AppColors.neonViolet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.signal_cellular_alt,
            title: 'Signal',
            value: '$_connectionQuality%',
            subtitle: 'qualité',
            color: AppColors.neonGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(16),
      glowColor: color,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      enableGlow: true,
      glowColor: AppColors.electricBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppGradients.electricBlueGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abonnement actuel',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _currentPlan,
                      style: AppTextStyles.h6.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIF',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Barre de progression
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Données utilisées',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '$_dataUsed / $_dataRemaining',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.65,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.electricBlueGradient,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bouton renouveler
          NeonOutlinedButton(
            text: 'Voir les forfaits',
            icon: Icons.arrow_forward,
            color: AppColors.electricBlue,
            onPressed: () => Navigator.pushNamed(context, '/subscriptions'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: AppTextStyles.h6.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Scanner',
                subtitle: 'QR Voucher',
                color: AppColors.neonViolet,
                onTap: () => Navigator.pushNamed(context, '/qrscan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher',
                subtitle: 'Entrer code',
                color: AppColors.modernTurquoise,
                onTap: () => Navigator.pushNamed(context, '/voucher'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.history_rounded,
                title: 'Historique',
                subtitle: 'Connexions',
                color: AppColors.neonGreen,
                onTap: () => Navigator.pushNamed(context, '/connections'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.payment_rounded,
                title: 'Paiement',
                subtitle: 'Mobile Money',
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, '/payment'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedGlassCard(
      onTap: onTap,
      glowColor: color,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: color.withOpacity(0.5),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Forfaits populaires',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/subscriptions'),
              child: Text(
                'Voir tout',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.modernTurquoise,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildPlanCard(
                name: 'Starter',
                duration: '1 heure',
                price: '500 GNF',
                color: AppColors.modernTurquoise,
                isPopular: false,
              ),
              _buildPlanCard(
                name: 'Basic',
                duration: '3 heures',
                price: '1 500 GNF',
                color: AppColors.neonViolet,
                isPopular: true,
              ),
              _buildPlanCard(
                name: 'Premium',
                duration: '24 heures',
                price: '5 000 GNF',
                color: AppColors.electricBlue,
                isPopular: false,
              ),
              _buildPlanCard(
                name: 'Ultimate',
                duration: '7 jours',
                price: '25 000 GNF',
                color: AppColors.warning,
                isPopular: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String duration,
    required String price,
    required Color color,
    bool isPopular = false,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        enableGlow: isPopular,
        glowColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'POPULAIRE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontSize: 9,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              name,
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              duration,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: AppTextStyles.bodyLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

