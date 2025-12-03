// lib/screens/auth/reset_password_screen.dart
// 🔐 BARRY WI-FI - Reset Password Screen Premium 5G

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/input_field.dart';
import '../../core/widgets/animated_logo.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late AnimationController _fadeController;
  bool _isLoading = false;

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
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.resetPassword(
        _codeController.text.trim(),
        _passwordController.text,
      );

      if (result['success'] == true) {
        if (mounted) {
          _showSuccess('Mot de passe réinitialisé avec succès');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          });
        }
      } else {
        _showError(result['message'] ?? 'Erreur lors de la réinitialisation');
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

                    const SizedBox(height: 40),

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
                        'Nouveau mot de passe',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Entrez le code reçu par SMS\net choisissez un nouveau mot de passe',
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
                      text: 'RÉINITIALISER',
                      icon: Icons.lock_reset_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleReset,
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
            'Réinitialisation',
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
            // Code de vérification
            GlassInputField(
              label: 'Code de vérification',
              hint: 'XXXXXX',
              controller: _codeController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.pin_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le code';
                }
                if (value.length < 4) {
                  return 'Code invalide';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Nouveau mot de passe
            GlassInputField(
              label: 'Nouveau mot de passe',
              hint: '••••••••',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                if (value.length < 6) {
                  return 'Minimum 6 caractères';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Confirmer mot de passe
            GlassInputField(
              label: 'Confirmer le mot de passe',
              hint: '••••••••',
              controller: _confirmController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
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
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          ),
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

