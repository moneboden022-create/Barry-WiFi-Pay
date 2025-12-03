// lib/screens/auth/forgot_password_screen.dart
// 🔓 BARRY WI-FI - Forgot Password Screen Premium 5G

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/input_field.dart';
import '../../core/widgets/animated_logo.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  late AnimationController _fadeController;
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.forgotPassword(_phoneController.text.trim());

      if (result['success'] == true) {
        setState(() => _codeSent = true);
        if (mounted) {
          _showSuccess('Code envoyé par SMS');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                '/reset',
                arguments: _phoneController.text.trim(),
              );
            }
          });
        }
      } else {
        _showError(result['message'] ?? 'Erreur lors de l\'envoi');
      }
    } catch (e) {
      _showError('Erreur de connexion au serveur');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Header avec retour
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Logo
                    const AnimatedLogo(
                      size: 80,
                      showText: false,
                      enable3DEffect: true,
                    ),

                    const SizedBox(height: 32),

                    // Titre
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppGradients.neonRainbow.createShader(bounds),
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Entrez votre numéro de téléphone pour\nrecevoir un code de réinitialisation',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Formulaire
                    _buildForm(),

                    const SizedBox(height: 32),

                    // Bouton
                    NeonButton(
                      text: _codeSent ? 'CODE ENVOYÉ ✓' : 'ENVOYER LE CODE',
                      icon: _codeSent ? Icons.check : Icons.send_rounded,
                      isLoading: _isLoading,
                      gradient: _codeSent
                          ? const LinearGradient(colors: [AppColors.neonGreen, AppColors.neonGreen])
                          : null,
                      onPressed: _codeSent ? () {} : _handleSendCode,
                    ),

                    const SizedBox(height: 24),

                    // Retour connexion
                    _buildBackToLogin(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
        Expanded(
          child: Text(
            'Récupération de compte',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          children: [
            // Icône téléphone
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neonViolet.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                size: 40,
                color: AppColors.neonViolet,
              ),
            ),

            const SizedBox(height: 24),

            GlassInputField(
              label: 'Numéro de téléphone',
              hint: '+224 XXX XXX XXX',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre numéro';
                }
                if (value.length < 8) {
                  return 'Numéro invalide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous vous souvenez ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Connectez-vous',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neonViolet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

