// lib/screens/admin/admin_dashboard_screen.dart
// 🛡️ BARRY WI-FI - Admin Dashboard Premium 5G

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/animated_logo.dart';
import '../../services/admin_service.dart';
import '../../services/admin_auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;

  bool _isLoading = true;
  String _adminName = "Admin";
  String _adminRole = "admin";

  // Stats
  Map<String, dynamic> _overview = {};
  List<Map<String, dynamic>> _dailyConnections = [];
  Map<String, dynamic> _weeklyComparison = {};

  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // 🔥 Vérifier l'authentification admin avant de charger les données
    _checkAuthAndLoad();
  }

  /// 🔐 Vérifie si l'admin est authentifié, sinon redirige vers le login
  Future<void> _checkAuthAndLoad() async {
    final isLoggedIn = await AdminAuthService.isLoggedIn();
    final isAdmin = await AdminAuthService.isAdmin();
    
    if (!isLoggedIn || !isAdmin) {
      // 🔥 Non authentifié → rediriger vers le login admin
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/admin/login');
      }
      return;
    }
    
    // 🔥 Authentifié → charger les données
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final name = await AdminAuthService.getName();
      final role = await AdminAuthService.getRole();
      final overview = await AdminService.getOverviewStats();
      final connections = await AdminService.getDailyConnections(days: 7);
      final weekly = await AdminService.getWeeklyComparison();

      // 🔥 Vérifier si les données ont été récupérées avec succès
      if (overview.containsKey('error') && overview['error'] == 'Non authentifié') {
        // Session expirée
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin/login');
        }
        return;
      }

      setState(() {
        _adminName = name ?? "Admin";
        _adminRole = role ?? "admin";
        _overview = overview;
        _dailyConnections = connections;
        _weeklyComparison = weekly;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Row(
          children: [
            // Sidebar
            _buildSidebar(),

            // Main content
            Expanded(
              child: SafeArea(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: _isLoading
                      ? _buildLoading()
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(child: _buildHeader()),
                            SliverPadding(
                              padding: const EdgeInsets.all(24),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildWelcomeCard(),
                                  const SizedBox(height: 24),
                                  _buildQuickStats(),
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: _buildConnectionsChart(),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildRevenueCard(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildWeeklyComparison(),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildQuickActions(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 100),
                                ]),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateVoucherDialog,
        backgroundColor: AppColors.neonViolet,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Voucher'),
      ),
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      _SidebarItem(Icons.dashboard, 'Dashboard', 0),
      _SidebarItem(Icons.people, 'Utilisateurs', 1),
      _SidebarItem(Icons.confirmation_number, 'Vouchers', 2),
      _SidebarItem(Icons.wifi, 'Connexions', 3),
      _SidebarItem(Icons.devices, 'Appareils', 4),
      _SidebarItem(Icons.bar_chart, 'Statistiques', 5),
      _SidebarItem(Icons.map, 'Zones', 6),
      _SidebarItem(Icons.settings, 'Paramètres', 7),
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.5),
        border: Border(
          right: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Column(
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GlowingLogo(size: 48),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppGradients.neonRainbow.createShader(bounds),
                            child: Text(
                              'BARRY WI-FI',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'Admin Panel',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.darkBorder, height: 1),

                // Menu items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      final isSelected = _selectedNavIndex == item.index;
                      return _buildSidebarItem(item, isSelected);
                    },
                  ),
                ),

                const Divider(color: AppColors.darkBorder, height: 1),

                // Admin info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.neonVioletGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _adminName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _adminRole.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.warning,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.logout,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(_SidebarItem item, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _selectedNavIndex = item.index);
            _navigateToSection(item.index);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected ? AppGradients.neonVioletGradient : null,
              color: isSelected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.neonViolet.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.neonViolet),
          SizedBox(height: 16),
          Text(
            'Chargement...',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tableau de bord',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Vue d\'ensemble en temps réel',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _loadData,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.modernTurquoise,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen.withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'En ligne',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.neonGreen,
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

  Widget _buildWelcomeCard() {
    return GradientCard(
      gradient: AppGradients.primaryPremium,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue, $_adminName 👋',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez votre réseau BARRY WI-FI depuis ce tableau de bord.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                NeonOutlinedButton(
                  text: 'Voir les rapports',
                  icon: Icons.analytics,
                  color: Colors.white,
                  width: 180,
                  height: 44,
                  onPressed: () => Navigator.pushNamed(context, '/admin/stats'),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard,
              size: 50,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final users = _overview["users"] ?? {};
    final connections = _overview["connections"] ?? {};
    final vouchers = _overview["vouchers"] ?? {};
    final devices = _overview["devices"] ?? {};

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Utilisateurs',
            '${users["total"] ?? 0}',
            Icons.people,
            AppColors.electricBlue,
            '+${users["today"] ?? 0} aujourd\'hui',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Connexions',
            '${connections["today"] ?? 0}',
            Icons.wifi,
            AppColors.neonGreen,
            '${connections["active_now"] ?? 0} actives',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Vouchers',
            '${vouchers["available"] ?? 0}',
            Icons.confirmation_number,
            AppColors.warning,
            '${vouchers["used"] ?? 0} utilisés',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Appareils',
            '${devices["total"] ?? 0}',
            Icons.devices,
            AppColors.cyberPurple,
            '${devices["blocked"] ?? 0} bloqués',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return AnimatedGlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: AppTextStyles.h3.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    );
  }

  Widget _buildConnectionsChart() {
    if (_dailyConnections.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connexions (7 jours)',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppColors.neonGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+12%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.darkBorder,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _dailyConnections.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _dailyConnections[index]["label"] ?? "",
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _dailyConnections.asMap().entries.map((e) {
                      return FlSpot(
                        e.key.toDouble(),
                        (e.value["connections"] ?? 0).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: AppGradients.neonVioletGradient,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.neonViolet.withOpacity(0.3),
                          AppColors.neonViolet.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.neonViolet,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard() {
    final revenue = _overview["revenue"] ?? {};
    final total = revenue["total"] ?? 0;
    final today = revenue["today"] ?? 0;
    final currency = revenue["currency"] ?? "GNF";

    return GlassCard(
      padding: const EdgeInsets.all(24),
      enableGlow: true,
      glowColor: AppColors.neonGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppGradients.successGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Revenus',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$total $currency',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.neonGreen,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$today $currency aujourd\'hui',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.neonGreen,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    value: 40,
                    title: '40%',
                    color: AppColors.neonViolet,
                    radius: 30,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 35,
                    title: '35%',
                    color: AppColors.modernTurquoise,
                    radius: 30,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    title: '25%',
                    color: AppColors.warning,
                    radius: 30,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyComparison() {
    final thisWeek = _weeklyComparison["this_week"] ?? {};
    final changes = _weeklyComparison["changes"] ?? {};

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cette semaine vs Précédente',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildComparisonItem(
                  'Connexions',
                  '${thisWeek["connections"] ?? 0}',
                  changes["connections"] ?? 0,
                  AppColors.neonViolet,
                ),
              ),
              Expanded(
                child: _buildComparisonItem(
                  'Nouveaux',
                  '${thisWeek["new_users"] ?? 0}',
                  changes["new_users"] ?? 0,
                  AppColors.modernTurquoise,
                ),
              ),
              Expanded(
                child: _buildComparisonItem(
                  'Vouchers',
                  '${thisWeek["vouchers_used"] ?? 0}',
                  changes["vouchers_used"] ?? 0,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(
    String label,
    String value,
    num change,
    Color color,
  ) {
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? AppColors.neonGreen : AppColors.error,
                size: 14,
              ),
              Text(
                '${change.abs()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isPositive ? AppColors.neonGreen : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions rapides',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(
                'Vouchers',
                Icons.confirmation_number,
                AppColors.warning,
                () => Navigator.pushNamed(context, '/admin/vouchers'),
              ),
              _buildActionButton(
                'Users',
                Icons.people,
                AppColors.electricBlue,
                () => Navigator.pushNamed(context, '/admin/users'),
              ),
              _buildActionButton(
                'Devices',
                Icons.devices,
                AppColors.cyberPurple,
                () => Navigator.pushNamed(context, '/admin/devices'),
              ),
              _buildActionButton(
                'Stats',
                Icons.bar_chart,
                AppColors.modernTurquoise,
                () => Navigator.pushNamed(context, '/admin/stats'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSection(int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/admin/users');
        break;
      case 2:
        Navigator.pushNamed(context, '/admin/vouchers');
        break;
      case 3:
        Navigator.pushNamed(context, '/admin/connections');
        break;
      case 4:
        Navigator.pushNamed(context, '/admin/devices');
        break;
      case 5:
        Navigator.pushNamed(context, '/admin/stats');
        break;
      case 6:
        Navigator.pushNamed(context, '/admin/zones');
        break;
      case 7:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  void _showCreateVoucherDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _VoucherCreationSheet(onCreated: _loadData),
    );
  }

  Future<void> _logout() async {
    await AdminAuthService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  _SidebarItem(this.icon, this.label, this.index);
}

class _VoucherCreationSheet extends StatefulWidget {
  final VoidCallback onCreated;

  const _VoucherCreationSheet({required this.onCreated});

  @override
  State<_VoucherCreationSheet> createState() => _VoucherCreationSheetState();
}

class _VoucherCreationSheetState extends State<_VoucherCreationSheet> {
  String _type = "individual";
  int _duration = 60;
  int _quantity = 1;
  bool _loading = false;

  Future<void> _create() async {
    setState(() => _loading = true);

    final result = await AdminService.createVoucher(
      type: _type,
      durationMinutes: _duration,
      quantity: _quantity,
    );

    setState(() => _loading = false);

    if (result["ok"] == true) {
      widget.onCreated();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${result["data"]?["created"] ?? _quantity} voucher(s) créé(s)",
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["error"] ?? "Erreur"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Créer un Voucher',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Type
          Text(
            'Type',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _type,
            dropdownColor: AppColors.darkCard,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBorder.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: "individual",
                child: Text("Individual (1 appareil)"),
              ),
              DropdownMenuItem(
                value: "business",
                child: Text("Business (3 appareils)"),
              ),
              DropdownMenuItem(
                value: "enterprise",
                child: Text("Enterprise (10 appareils)"),
              ),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 20),

          // Durée
          Text(
            'Durée: $_duration minutes (${(_duration / 60).toStringAsFixed(1)}h)',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Slider(
            value: _duration.toDouble(),
            min: 30,
            max: 1440,
            divisions: 28,
            activeColor: AppColors.neonViolet,
            inactiveColor: AppColors.darkBorder,
            onChanged: (v) => setState(() => _duration = v.toInt()),
          ),
          const SizedBox(height: 16),

          // Quantité
          Row(
            children: [
              Text(
                'Quantité: ',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              IconButton(
                onPressed:
                    _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: Icon(
                  Icons.remove_circle,
                  color: AppColors.neonViolet,
                ),
              ),
              Text(
                '$_quantity',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed:
                    _quantity < 100 ? () => setState(() => _quantity++) : null,
                icon: Icon(
                  Icons.add_circle,
                  color: AppColors.neonViolet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          NeonButton(
            text: 'CRÉER VOUCHER(S)',
            icon: Icons.add,
            isLoading: _loading,
            onPressed: _create,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
