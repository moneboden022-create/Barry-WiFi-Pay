// lib/screens/qr_scanner/qr_scanner_screen.dart
// 📷 BARRY WI-FI - QR Scanner Screen Premium 5G

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanAnimController;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  void _onQRCodeScanned(String code) {
    // Vibration feedback
    Navigator.pushReplacementNamed(
      context,
      '/voucher',
      arguments: code,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zone de scan (placeholder pour caméra)
          _buildCameraPreview(),

          // Overlay avec cadre
          _buildScannerOverlay(),

          // Header
          _buildHeader(),

          // Contrôles en bas
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    // Placeholder - Intégrer mobile_scanner ou qr_code_scanner ici
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            AppColors.darkBackground,
            Colors.black,
          ],
          center: Alignment.center,
          radius: 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: AppColors.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aperçu Caméra',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          // Zone transparente au centre
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Corners
                  ..._buildCorners(),

                  // Ligne de scan animée
                  AnimatedBuilder(
                    animation: _scanAnimController,
                    builder: (context, child) {
                      return Positioned(
                        top: 20 + (_scanAnimController.value * 240),
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: AppGradients.neonVioletGradient,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonViolet.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 + 180,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Placez le QR code dans le cadre',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Le scan est automatique',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 30.0;
    const cornerWidth = 4.0;

    Widget buildCorner(Alignment alignment) {
      return Positioned(
        top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? 0 : null,
        bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? 0 : null,
        left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? 0 : null,
        right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? 0 : null,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                  ? const BorderSide(color: AppColors.neonViolet, width: cornerWidth)
                  : BorderSide.none,
              bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                  ? const BorderSide(color: AppColors.neonViolet, width: cornerWidth)
                  : BorderSide.none,
              left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                  ? const BorderSide(color: AppColors.neonViolet, width: cornerWidth)
                  : BorderSide.none,
              right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                  ? const BorderSide(color: AppColors.neonViolet, width: cornerWidth)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      buildCorner(Alignment.topLeft),
      buildCorner(Alignment.topRight),
      buildCorner(Alignment.bottomLeft),
      buildCorner(Alignment.bottomRight),
    ];
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppGradients.neonRainbow.createShader(bounds),
                    child: Text(
                      'Scanner QR',
                      style: AppTextStyles.h5.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Scannez un voucher Wi-Fi',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Boutons contrôle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Flash
                  _buildControlButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    label: 'Flash',
                    isActive: _isFlashOn,
                    onTap: () => setState(() => _isFlashOn = !_isFlashOn),
                  ),

                  // Scanner manuel
                  _buildControlButton(
                    icon: Icons.keyboard,
                    label: 'Manuel',
                    isActive: false,
                    onTap: () => _showManualEntry(),
                  ),

                  // Caméra
                  _buildControlButton(
                    icon: Icons.flip_camera_ios_rounded,
                    label: 'Caméra',
                    isActive: _isFrontCamera,
                    onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Bouton gallerie
              GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 16,
                child: InkWell(
                  onTap: () {
                    // TODO: Pick from gallery
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Import depuis galerie à venir'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Importer depuis la galerie',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.neonViolet.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.neonViolet
                    : Colors.white.withOpacity(0.1),
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.neonViolet.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.neonViolet : Colors.white70,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.neonViolet : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntry() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de drag
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Entrer le code manuellement',
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Saisissez le code du voucher',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: controller,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'XXXX-XXXX-XXXX',
                  hintStyle: AppTextStyles.h5.copyWith(
                    color: AppColors.textMuted.withOpacity(0.3),
                  ),
                  filled: true,
                  fillColor: AppColors.darkBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.darkBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.neonViolet,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              NeonButton(
                text: 'VALIDER LE CODE',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Navigator.pop(context);
                    _onQRCodeScanned(controller.text);
                  }
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

