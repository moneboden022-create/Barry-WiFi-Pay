// lib/screens/wifi/wifi_control_screen.dart
// ⚡ BARRY WI-FI - Contrôle Wi-Fi Premium 5G

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class WifiControlScreen extends StatefulWidget {
  const WifiControlScreen({super.key});

  @override
  State<WifiControlScreen> createState() => _WifiControlScreenState();
}

class _WifiControlScreenState extends State<WifiControlScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _waveController;
  late AnimationController _glowController;

  bool _isConnected = false;
  bool _isLoading = false;
  String _connectionStatus = 'Déconnecté';
  String _ipAddress = '---';
  String _signalStrength = '0%';
  String _downloadSpeed = '0 Mbps';
  String _uploadSpeed = '0 Mbps';
  String _timeRemaining = '0h 0m';
  String _dataUsed = '0 MB';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isConnected = prefs.getBool("wifi_active") ?? false;
      _connectionStatus = _isConnected ? 'Connecté' : 'Déconnecté';
    });
    // TODO: Charger les vraies données depuis l'API
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _toggleConnection() async {
    setState(() => _isLoading = true);

    try {
      // Simuler le délai de connexion
      await Future.delayed(const Duration(seconds: 2));

      final newState = !_isConnected;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("wifi_active", newState);

      setState(() {
        _isConnected = newState;
        _connectionStatus = newState ? 'Connecté' : 'Déconnecté';
        if (newState) {
          _ipAddress = '192.168.1.${100 + math.Random().nextInt(50)}';
          _signalStrength = '${70 + math.Random().nextInt(25)}%';
          _downloadSpeed = '${20 + math.Random().nextInt(30)} Mbps';
          _uploadSpeed = '${5 + math.Random().nextInt(15)} Mbps';
        } else {
          _ipAddress = '---';
          _signalStrength = '0%';
          _downloadSpeed = '0 Mbps';
          _uploadSpeed = '0 Mbps';
        }
      });

      _showMessage(
        newState ? 'Connexion établie !' : 'Déconnecté',
        newState ? AppColors.success : AppColors.warning,
      );
    } catch (e) {
      _showMessage('Erreur de connexion', AppColors.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.success
                  ? Icons.check_circle
                  : color == AppColors.error
                      ? Icons.error
                      : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

              // Contenu
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Bouton Power
                      _buildPowerButton(),
                      const SizedBox(height: 40),

                      // Status
                      _buildStatusCard(),
                      const SizedBox(height: 20),

                      // Stats connexion
                      if (_isConnected) ...[
                        _buildConnectionStats(),
                        const SizedBox(height: 20),
                        _buildSpeedTest(),
                      ],
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
                Text(
                  'Contrôle Wi-Fi',
                  style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  _connectionStatus,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _isConnected
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Indicateur signal
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (_isConnected ? AppColors.success : AppColors.error)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? AppColors.success : AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  _signalStrength,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: _isConnected ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerButton() {
    final color = _isConnected ? AppColors.neonGreen : AppColors.error;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _rotationController,
        _waveController,
        _glowController,
      ]),
      builder: (context, child) {
        return GestureDetector(
          onTap: _isLoading ? null : _toggleConnection,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ondes radar si connecté
                if (_isConnected)
                  ...List.generate(3, (index) {
                    final delay = index * 0.33;
                    final animValue = (_waveController.value + delay) % 1.0;
                    return Opacity(
                      opacity: (1 - animValue) * 0.4,
                      child: Container(
                        width: 200 + (animValue * 80),
                        height: 200 + (animValue * 80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color,
                            width: 2 * (1 - animValue),
                          ),
                        ),
                      ),
                    );
                  }),

                // Cercle externe pulsant
                Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(0.2 * _glowController.value),
                          color.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Cercle rotatif
                Transform.rotate(
                  angle: _rotationController.value * math.pi * 2,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          color.withOpacity(0.6),
                          color.withOpacity(0.1),
                          color.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bouton principal
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkCard,
                        AppColors.darkBackground,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          )
                        : Icon(
                            Icons.power_settings_new,
                            size: 80,
                            color: color,
                            shadows: [
                              Shadow(
                                color: color.withOpacity(0.8),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConnected ? Icons.check_circle : Icons.cancel,
                color: _isConnected ? AppColors.success : AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _isConnected ? 'Connexion Active' : 'Non Connecté',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _isConnected
                ? 'Vous êtes connecté au réseau BARRY WI-FI'
                : 'Appuyez sur le bouton pour vous connecter',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isConnected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppColors.modernTurquoise,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Temps restant: $_timeRemaining',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.modernTurquoise,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionStats() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de connexion',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.router_outlined,
            'Adresse IP',
            _ipAddress,
            AppColors.modernTurquoise,
          ),
          const Divider(color: AppColors.darkBorder, height: 24),
          _buildInfoRow(
            Icons.signal_cellular_alt,
            'Force du signal',
            _signalStrength,
            AppColors.neonGreen,
          ),
          const Divider(color: AppColors.darkBorder, height: 24),
          _buildInfoRow(
            Icons.data_usage,
            'Données utilisées',
            _dataUsed,
            AppColors.neonViolet,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedTest() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vitesse de connexion',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              NeonIconButton(
                icon: Icons.refresh,
                size: 40,
                color: AppColors.modernTurquoise,
                tooltip: 'Tester la vitesse',
                onPressed: () {
                  // TODO: Speed test
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSpeedCard(
                  icon: Icons.download_rounded,
                  label: 'Download',
                  value: _downloadSpeed,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSpeedCard(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  value: _uploadSpeed,
                  color: AppColors.modernTurquoise,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              color: color,
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
}

// Widget pour le bouton icon néon
class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 48,
    this.tooltip,
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.neonViolet;

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _isHovered ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(widget.size / 4),
            border: Border.all(
              color: _isHovered ? color : color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            widget.icon,
            color: color,
            size: widget.size * 0.5,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

