// lib/screens/history/history_screen.dart
// 📊 BARRY WI-FI - Historique des Connexions Premium 5G

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  List<Map<String, dynamic>> _connections = [];
  bool _isLoading = true;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() => _isLoading = true);

    // TODO: Charger depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _connections = [
        {
          'id': '1',
          'date': DateTime.now().subtract(const Duration(hours: 2)),
          'duration': '2h 30m',
          'dataUsed': '450 MB',
          'status': 'success',
          'device': 'iPhone 14 Pro',
          'plan': 'Premium 24h',
        },
        {
          'id': '2',
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'duration': '1h 15m',
          'dataUsed': '200 MB',
          'status': 'expired',
          'device': 'MacBook Pro',
          'plan': 'Basic 3h',
        },
        {
          'id': '3',
          'date': DateTime.now().subtract(const Duration(days: 2)),
          'duration': '45m',
          'dataUsed': '100 MB',
          'status': 'error',
          'device': 'Samsung Galaxy',
          'plan': 'Starter 1h',
        },
        {
          'id': '4',
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'duration': '5h 00m',
          'dataUsed': '1.2 GB',
          'status': 'success',
          'device': 'iPad Pro',
          'plan': 'Premium 24h',
        },
        {
          'id': '5',
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'duration': '3h 20m',
          'dataUsed': '800 MB',
          'status': 'success',
          'device': 'iPhone 14 Pro',
          'plan': 'Basic 3h',
        },
      ];
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConnections {
    if (_filterType == 'all') return _connections;
    return _connections.where((c) => c['status'] == _filterType).toList();
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
            child: Column(
              children: [
                _buildHeader(),
                _buildStats(),
                _buildFilters(),
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _filteredConnections.isEmpty
                          ? _buildEmpty()
                          : _buildTimeline(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppGradients.neonRainbow.createShader(bounds),
                  child: Text(
                    'Historique',
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  '${_connections.length} connexions',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadConnections,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.neonViolet.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: AppColors.neonViolet,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final successCount =
        _connections.where((c) => c['status'] == 'success').length;
    final totalData = '2.75 GB';
    final totalTime = '12h 50m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle_outline,
              label: 'Réussies',
              value: '$successCount',
              color: AppColors.neonGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              icon: Icons.data_usage,
              label: 'Données',
              value: totalData,
              color: AppColors.modernTurquoise,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatItem(
              icon: Icons.timer_outlined,
              label: 'Temps total',
              value: totalTime,
              color: AppColors.neonViolet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'Tout', Icons.list),
            const SizedBox(width: 10),
            _buildFilterChip('success', 'Réussies', Icons.check_circle),
            const SizedBox(width: 10),
            _buildFilterChip('expired', 'Expirées', Icons.access_time),
            const SizedBox(width: 10),
            _buildFilterChip('error', 'Erreurs', Icons.error_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type, String label, IconData icon) {
    final isSelected = _filterType == type;
    final color = _getStatusColor(type);

    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? color : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.neonViolet,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune connexion',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre historique apparaîtra ici',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredConnections.length,
      itemBuilder: (context, index) {
        final connection = _filteredConnections[index];
        final isLast = index == _filteredConnections.length - 1;
        return _buildTimelineItem(connection, isLast, index);
      },
    );
  }

  Widget _buildTimelineItem(
    Map<String, dynamic> connection,
    bool isLast,
    int index,
  ) {
    final status = connection['status'] as String;
    final color = _getStatusColor(status);
    final date = connection['date'] as DateTime;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(status),
                  size: 10,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.5),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: color.withOpacity(0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          connection['device'] ?? '',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(status),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM yyyy • HH:mm', 'fr').format(date),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.darkBorder),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildConnectionDetail(
                          Icons.timer_outlined,
                          'Durée',
                          connection['duration'] ?? '',
                        ),
                        const SizedBox(width: 20),
                        _buildConnectionDetail(
                          Icons.data_usage,
                          'Données',
                          connection['dataUsed'] ?? '',
                        ),
                        const SizedBox(width: 20),
                        _buildConnectionDetail(
                          Icons.wifi,
                          'Forfait',
                          connection['plan'] ?? '',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionDetail(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.neonGreen;
      case 'expired':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.neonViolet;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check;
      case 'expired':
        return Icons.access_time;
      case 'error':
        return Icons.close;
      default:
        return Icons.circle;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Réussie';
      case 'expired':
        return 'Expirée';
      case 'error':
        return 'Erreur';
      default:
        return status;
    }
  }
}

