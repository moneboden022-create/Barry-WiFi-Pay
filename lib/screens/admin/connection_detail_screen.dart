// lib/screens/admin/connection_detail_screen.dart
// 📡 BARRY WI-FI - Connection Detail Screen Admin 5G

import 'package:flutter/material.dart';
import '../../models/connection_model.dart';
import '../../services/connection_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';

class ConnectionDetailScreen extends StatefulWidget {
  final ConnectionModel conn;
  const ConnectionDetailScreen({super.key, required this.conn});

  @override
  State<ConnectionDetailScreen> createState() => _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends State<ConnectionDetailScreen> {
  bool _isWorking = false;

  Future<void> _blockDevice() async {
    setState(() => _isWorking = true);
    final ok = await ConnectionService.blockDevice(widget.conn.deviceId);
    if (mounted) {
      setState(() => _isWorking = false);
      _showMessage(ok ? "Appareil bloqué avec succès" : "Erreur lors du blocage");
    }
  }

  Future<void> _unblockDevice() async {
    setState(() => _isWorking = true);
    final ok = await ConnectionService.unblockDevice(widget.conn.deviceId);
    if (mounted) {
      setState(() => _isWorking = false);
      _showMessage(ok ? "Appareil débloqué" : "Erreur lors du déblocage");
    }
  }

  Future<void> _disableWifi() async {
    setState(() => _isWorking = true);
    final ok = await ConnectionService.disableWifiForUser(widget.conn.userId);
    if (mounted) {
      setState(() => _isWorking = false);
      _showMessage(ok ? "Wi-Fi désactivé pour l'utilisateur" : "Erreur");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conn;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Status card
                      _buildStatusCard(c),
                      const SizedBox(height: 20),

                      // Details
                      _buildDetailsCard(c),
                      const SizedBox(height: 20),

                      // Actions
                      _buildActionsCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Détail de connexion',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(ConnectionModel c) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      enableGlow: true,
      glowColor: c.success ? AppColors.neonGreen : AppColors.error,
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: (c.success ? AppColors.neonGreen : AppColors.error)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              c.success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: c.success ? AppColors.neonGreen : AppColors.error,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.ip,
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (c.success ? AppColors.neonGreen : AppColors.error)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    c.success ? 'SUCCÈS' : 'ÉCHEC',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: c.success ? AppColors.neonGreen : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ConnectionModel c) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow(Icons.person_outline, 'User ID', '${c.userId}'),
          _buildDetailRow(Icons.devices, 'Device ID', c.deviceId),
          if (c.deviceName != null)
            _buildDetailRow(Icons.phone_android, 'Appareil', c.deviceName!),
          if (c.macAddress != null)
            _buildDetailRow(Icons.router, 'MAC Address', c.macAddress!),
          if (c.voucherCode != null)
            _buildDetailRow(Icons.confirmation_number, 'Voucher', c.voucherCode!),
          _buildDetailRow(Icons.access_time, 'Début', c.startAt.toString()),
          if (c.endAt != null)
            _buildDetailRow(Icons.timer_off, 'Fin', c.endAt.toString()),
          _buildDetailRow(Icons.schedule, 'Durée', c.formattedDuration),
          if (c.dataUsed != null)
            _buildDetailRow(Icons.data_usage, 'Données', c.formattedDataUsed),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.neonViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.neonViolet, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (_isWorking)
            const LinearProgressIndicator(
              color: AppColors.neonViolet,
              backgroundColor: AppColors.darkBorder,
            ),
          const SizedBox(height: 12),

          // Bloquer
          NeonButton(
            text: 'Bloquer l\'appareil',
            icon: Icons.block_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.error, Color(0xFFFF6B6B)],
            ),
            isLoading: _isWorking,
            onPressed: _blockDevice,
          ),
          const SizedBox(height: 12),

          // Débloquer
          NeonOutlinedButton(
            text: 'Débloquer l\'appareil',
            icon: Icons.check_circle_outline,
            color: AppColors.neonGreen,
            onPressed: _isWorking ? () {} : _unblockDevice,
          ),
          const SizedBox(height: 12),

          // Désactiver Wi-Fi
          NeonOutlinedButton(
            text: 'Désactiver Wi-Fi utilisateur',
            icon: Icons.wifi_off_rounded,
            color: AppColors.warning,
            onPressed: _isWorking ? () {} : _disableWifi,
          ),
        ],
      ),
    );
  }
}
