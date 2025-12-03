// lib/screens/legal/privacy_policy_screen.dart
// 🔒 BARRY WI-FI - Privacy Policy Screen Premium 5G

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                    // Titre
                    _buildTitleSection(),
                    const SizedBox(height: 24),

                    // Introduction
                    _buildIntroCard(),
                    const SizedBox(height: 16),

                    // Sections
                    _buildSection(
                      '1. Données collectées',
                      'Nous collectons les données suivantes :\n\n'
                      '• Informations de compte : nom, prénom, numéro de téléphone\n'
                      '• Données de connexion : adresse MAC, historique de connexion\n'
                      '• Données de paiement : historique des transactions\n'
                      '• Données d\'utilisation : temps de connexion, volume de données',
                      Icons.data_usage_rounded,
                      AppColors.electricBlue,
                    ),

                    _buildSection(
                      '2. Utilisation des données',
                      'Vos données sont utilisées pour :\n\n'
                      '• Fournir et améliorer nos services\n'
                      '• Traiter vos paiements et forfaits\n'
                      '• Assurer la sécurité du réseau\n'
                      '• Vous contacter pour le support client\n'
                      '• Personnaliser votre expérience',
                      Icons.settings_applications_rounded,
                      AppColors.neonViolet,
                    ),

                    _buildSection(
                      '3. Protection des données',
                      'Nous mettons en œuvre des mesures de sécurité robustes :\n\n'
                      '• Chiffrement des données sensibles\n'
                      '• Authentification sécurisée\n'
                      '• Serveurs protégés\n'
                      '• Accès restreint aux données personnelles',
                      Icons.security_rounded,
                      AppColors.neonGreen,
                    ),

                    _buildSection(
                      '4. Partage des données',
                      'Nous ne vendons jamais vos données. Elles peuvent être partagées avec :\n\n'
                      '• Nos prestataires de paiement (Orange, MTN)\n'
                      '• Les autorités si requis par la loi\n'
                      '• Nos partenaires techniques (avec votre consentement)',
                      Icons.share_rounded,
                      AppColors.warning,
                    ),

                    _buildSection(
                      '5. Conservation des données',
                      'Vos données sont conservées :\n\n'
                      '• Données de compte : tant que le compte est actif\n'
                      '• Historique de connexion : 12 mois\n'
                      '• Données de paiement : 5 ans (obligation légale)\n\n'
                      'Vous pouvez demander la suppression de vos données à tout moment.',
                      Icons.access_time_rounded,
                      AppColors.modernTurquoise,
                    ),

                    _buildSection(
                      '6. Vos droits',
                      'Conformément à la réglementation, vous avez le droit de :\n\n'
                      '• Accéder à vos données personnelles\n'
                      '• Rectifier vos informations\n'
                      '• Supprimer votre compte et vos données\n'
                      '• Exporter vos données\n'
                      '• Vous opposer au traitement',
                      Icons.gavel_rounded,
                      AppColors.neonViolet,
                    ),

                    _buildSection(
                      '7. Cookies et traceurs',
                      'L\'application utilise des technologies de suivi pour :\n\n'
                      '• Maintenir votre session connectée\n'
                      '• Améliorer les performances\n'
                      '• Analyser l\'utilisation de l\'app',
                      Icons.cookie_rounded,
                      AppColors.electricBlue,
                    ),

                    _buildSection(
                      '8. Modifications',
                      'Cette politique peut être mise à jour. En cas de modification importante, '
                      'nous vous en informerons via l\'application ou par SMS.',
                      Icons.update_rounded,
                      AppColors.neonGreen,
                    ),

                    _buildSection(
                      '9. Contact DPO',
                      'Pour toute question concernant vos données :\n\n'
                      '📧 privacy@barrywifi.gn\n'
                      '📞 +224 XXX XXX XXX\n'
                      '📍 Conakry, Guinée',
                      Icons.contact_mail_outlined,
                      AppColors.warning,
                    ),

                    const SizedBox(height: 20),

                    // Footer
                    _buildFooter(),
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
            'Politique de confidentialité',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      enableGlow: true,
      glowColor: AppColors.electricBlue,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppGradients.electricBlueGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.privacy_tip_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppGradients.neonRainbow.createShader(bounds),
            child: Text(
              'Politique de Confidentialité',
              style: AppTextStyles.h4.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dernière mise à jour : Décembre 2025',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.neonGreen,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre vie privée compte',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Nous nous engageons à protéger vos données personnelles.',
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

  Widget _buildSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h6.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                color: AppColors.neonGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Vos données sont en sécurité',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neonGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '© 2025 BARRY WI-FI. Tous droits réservés.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.electricBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

