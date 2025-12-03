// lib/screens/legal/about_screen.dart
// ℹ️ BARRY WI-FI - About Screen Premium 5G

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/animated_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(context),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Logo et titre
                    _buildLogoSection(),
                    const SizedBox(height: 32),

                    // Description
                    _buildDescriptionCard(),
                    const SizedBox(height: 20),

                    // Features
                    _buildFeaturesCard(),
                    const SizedBox(height: 20),

                    // Team
                    _buildTeamCard(),
                    const SizedBox(height: 20),

                    // Version
                    _buildVersionCard(),
                    const SizedBox(height: 20),

                    // Contact
                    _buildContactCard(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'À propos',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        const AnimatedLogo(
          size: 100,
          showText: false,
          enable3DEffect: true,
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppGradients.neonRainbow.createShader(bounds),
          child: Text(
            'BARRY WI-FI',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous au futur',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.neonViolet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.neonViolet,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Notre mission',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'BARRY WI-FI est une plateforme innovante de distribution de connexion Wi-Fi en Guinée. '
            'Notre objectif est de rendre l\'accès à internet simple, abordable et accessible à tous.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Grâce à notre technologie Starlink et notre réseau de distribution de vouchers, '
            'nous connectons les Guinéens au monde entier.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.modernTurquoise.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.modernTurquoise,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Fonctionnalités',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            Icons.wifi_rounded,
            'Connexion haute vitesse',
            'Internet rapide via Starlink',
          ),
          _buildFeatureItem(
            Icons.qr_code_scanner_rounded,
            'Vouchers QR Code',
            'Scan et connectez-vous instantanément',
          ),
          _buildFeatureItem(
            Icons.payments_rounded,
            'Mobile Money',
            'Paiement Orange et MTN',
          ),
          _buildFeatureItem(
            Icons.business_rounded,
            'Plans Entreprise',
            'Solutions pour professionnels',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.electricBlue, size: 22),
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
        ],
      ),
    );
  }

  Widget _buildTeamCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.neonGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Notre équipe',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'BARRY WI-FI est développé par une équipe passionnée de développeurs guinéens, '
            'déterminés à révolutionner l\'accès à internet en Afrique de l\'Ouest.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppGradients.neonVioletGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '1.0.0 (Build 5G)',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'STABLE',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.contact_support_rounded,
                  color: AppColors.warning,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Contact',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(Icons.email_outlined, 'contact@barrywifi.gn'),
          _buildContactItem(Icons.phone_outlined, '+224 XXX XXX XXX'),
          _buildContactItem(Icons.location_on_outlined, 'Conakry, Guinée'),
          _buildContactItem(Icons.language_outlined, 'www.barrywifi.gn'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

