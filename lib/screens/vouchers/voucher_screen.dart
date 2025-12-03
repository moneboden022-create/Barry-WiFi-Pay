// lib/screens/vouchers/voucher_screen.dart
// 🎫 BARRY WI-FI - Voucher Screen Premium 5G

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/input_field.dart';

class VoucherScreen extends StatefulWidget {
  final String? scannedCode;

  const VoucherScreen({super.key, this.scannedCode});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();

  late AnimationController _fadeController;
  late TabController _tabController;

  bool _isActivating = false;
  List<Map<String, dynamic>> _myVouchers = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _tabController = TabController(length: 2, vsync: this);

    if (widget.scannedCode != null) {
      _codeController.text = widget.scannedCode!;
    }

    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    // TODO: Charger les vouchers depuis l'API
    setState(() {
      _myVouchers = [
        {
          'code': 'BARRY-XXXX-YYYY',
          'duration': '3 heures',
          'status': 'active',
          'expiresAt': '2024-12-15',
        },
        {
          'code': 'BARRY-AAAA-BBBB',
          'duration': '24 heures',
          'status': 'used',
          'expiresAt': '2024-12-10',
        },
      ];
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _activateVoucher() async {
    if (_codeController.text.isEmpty) {
      _showMessage('Veuillez entrer un code voucher', AppColors.warning);
      return;
    }

    setState(() => _isActivating = true);

    try {
      // TODO: Activer le voucher via l'API
      await Future.delayed(const Duration(seconds: 2));

      _showMessage('Voucher activé avec succès !', AppColors.success);
      _codeController.clear();
    } catch (e) {
      _showMessage('Erreur lors de l\'activation', AppColors.error);
    } finally {
      setState(() => _isActivating = false);
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
                      : Icons.warning,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
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
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActivateTab(),
                      _buildMyVouchersTab(),
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
                    'Vouchers',
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  'Activez ou gérez vos codes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/qrscan'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppGradients.neonVioletGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonViolet.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.neonVioletGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonViolet.withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: AppTextStyles.buttonMedium,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Activer'),
          Tab(text: 'Mes Vouchers'),
        ],
      ),
    );
  }

  Widget _buildActivateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.neonVioletGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonViolet.withOpacity(0.4),
                  blurRadius: 30,
                ),
              ],
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Activer un voucher',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Entrez votre code voucher ou scannez le QR code',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Champ code
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GlassInputField(
                  label: 'Code Voucher',
                  hint: 'BARRY-XXXX-XXXX-XXXX',
                  controller: _codeController,
                  prefixIcon: Icons.vpn_key_outlined,
                  suffixIcon: Icons.paste,
                  onSuffixTap: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      _codeController.text = data!.text!;
                    }
                  },
                ),
                const SizedBox(height: 20),
                NeonButton(
                  text: 'ACTIVER LE VOUCHER',
                  icon: Icons.check_circle_outline,
                  isLoading: _isActivating,
                  onPressed: _activateVoucher,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Scanner option
          GlassCard(
            onTap: () => Navigator.pushNamed(context, '/qrscan'),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.modernTurquoise.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.modernTurquoise,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanner un QR Code',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Scannez le code sur votre ticket',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.modernTurquoise.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyVouchersTab() {
    if (_myVouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: AppColors.textMuted.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun voucher',
              style: AppTextStyles.h6.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos vouchers apparaîtront ici',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _myVouchers.length,
      itemBuilder: (context, index) {
        final voucher = _myVouchers[index];
        return _buildVoucherCard(voucher);
      },
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher) {
    final isActive = voucher['status'] == 'active';
    final color = isActive ? AppColors.neonGreen : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        enableGlow: isActive,
        glowColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isActive
                        ? Icons.check_circle_outline
                        : Icons.access_time,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher['code'] ?? '',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'Durée: ${voucher['duration']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'ACTIF' : 'UTILISÉ',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.darkBorder),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expire le: ${voucher['expiresAt']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showQRCode(voucher['code']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonViolet.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 16,
                            color: AppColors.neonViolet,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'QR Code',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.neonViolet,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQRCode(String code) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
          ),
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
              'QR Code Voucher',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: code,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.darkBackground,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              code,
              style: AppTextStyles.codeStyle.copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            NeonButton(
              text: 'Fermer',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

