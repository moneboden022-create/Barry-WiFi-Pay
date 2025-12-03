// lib/screens/legal/terms_screen.dart
// 📜 BARRY WI-FI - Terms Screen Premium 5G

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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

                    // Sections
                    _buildSection(
                      '1. Acceptation des conditions',
                      'En utilisant l\'application BARRY WI-FI, vous acceptez pleinement et sans réserve '
                      'les présentes conditions générales d\'utilisation. Si vous n\'acceptez pas ces conditions, '
                      'veuillez ne pas utiliser nos services.',
                      Icons.check_circle_outline,
                      AppColors.neonGreen,
                    ),

                    _buildSection(
                      '2. Description du service',
                      'BARRY WI-FI est un service de distribution de connexion internet Wi-Fi. '
                      'Les utilisateurs peuvent acheter des forfaits de connexion via des vouchers ou '
                      'des paiements mobile money. La qualité et la vitesse de connexion peuvent varier '
                      'selon la zone géographique et le nombre d\'utilisateurs connectés.',
                      Icons.wifi_rounded,
                      AppColors.electricBlue,
                    ),

                    _buildSection(
                      '3. Inscription et compte',
                      'Pour utiliser nos services, vous devez créer un compte avec des informations exactes. '
                      'Vous êtes responsable de la confidentialité de vos identifiants de connexion. '
                      'Un numéro de téléphone valide est requis pour la création du compte.',
                      Icons.person_outline_rounded,
                      AppColors.neonViolet,
                    ),

                    _buildSection(
                      '4. Tarification et paiement',
                      'Les tarifs des forfaits sont affichés dans l\'application en Franc Guinéen (GNF). '
                      'Les paiements peuvent être effectués via Orange Money, MTN Mobile Money ou vouchers prépayés. '
                      'Tous les paiements sont définitifs et non remboursables sauf indication contraire.',
                      Icons.payments_outlined,
                      AppColors.warning,
                    ),

                    _buildSection(
                      '5. Utilisation acceptable',
                      'Vous vous engagez à utiliser le service de manière légale et responsable. '
                      'Il est interdit d\'utiliser le service pour des activités illégales, '
                      'le téléchargement de contenus protégés par le droit d\'auteur, '
                      'ou toute activité portant atteinte aux droits d\'autrui.',
                      Icons.security_rounded,
                      AppColors.modernTurquoise,
                    ),

                    _buildSection(
                      '6. Limitation de responsabilité',
                      'BARRY WI-FI ne peut être tenu responsable des interruptions de service dues à des '
                      'facteurs externes (coupures d\'électricité, problèmes de réseau, etc.). '
                      'Notre responsabilité est limitée au montant payé pour le forfait concerné.',
                      Icons.info_outline_rounded,
                      AppColors.error,
                    ),

                    _buildSection(
                      '7. Propriété intellectuelle',
                      'L\'application BARRY WI-FI, son logo, son design et ses contenus sont protégés '
                      'par les lois sur la propriété intellectuelle. Toute reproduction ou utilisation '
                      'non autorisée est strictement interdite.',
                      Icons.copyright_rounded,
                      AppColors.neonViolet,
                    ),

                    _buildSection(
                      '8. Modification des conditions',
                      'BARRY WI-FI se réserve le droit de modifier ces conditions à tout moment. '
                      'Les utilisateurs seront informés des modifications importantes via l\'application. '
                      'L\'utilisation continue du service vaut acceptation des nouvelles conditions.',
                      Icons.edit_note_rounded,
                      AppColors.electricBlue,
                    ),

                    _buildSection(
                      '9. Contact',
                      'Pour toute question concernant ces conditions, contactez-nous à :\n'
                      '📧 legal@barrywifi.gn\n'
                      '📞 +224 XXX XXX XXX',
                      Icons.contact_mail_outlined,
                      AppColors.neonGreen,
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
            'Conditions d\'utilisation',
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
      glowColor: AppColors.neonViolet,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: AppGradients.neonVioletGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppGradients.neonRainbow.createShader(bounds),
            child: Text(
              'Conditions Générales',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neonViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '© 2025 BARRY WI-FI. Tous droits réservés.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neonViolet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

