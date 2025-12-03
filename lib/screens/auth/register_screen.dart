// lib/screens/auth/register_screen.dart
// 📝 BARRY WI-FI - Register Screen Premium 5G

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/input_field.dart';
import '../../core/widgets/animated_logo.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _avatarController;
  late Animation<double> _avatarScale;

  bool _isLoading = false;
  bool _isEnterprise = false;
  bool _acceptTerms = false;
  File? _avatarImage;
  String _selectedCountry = 'GN'; // Guinée par défaut

  final List<Map<String, String>> _countries = [
    {'code': 'GN', 'name': 'Guinée 🇬🇳', 'dial': '+224'},
    {'code': 'SN', 'name': 'Sénégal 🇸🇳', 'dial': '+221'},
    {'code': 'ML', 'name': 'Mali 🇲🇱', 'dial': '+223'},
    {'code': 'CI', 'name': 'Côte d\'Ivoire 🇨🇮', 'dial': '+225'},
    {'code': 'BF', 'name': 'Burkina Faso 🇧🇫', 'dial': '+226'},
    {'code': 'GH', 'name': 'Ghana 🇬🇭', 'dial': '+233'},
    {'code': 'NE', 'name': 'Niger 🇳🇪', 'dial': '+227'},
    {'code': 'TG', 'name': 'Togo 🇹🇬', 'dial': '+228'},
    {'code': 'BJ', 'name': 'Bénin 🇧🇯', 'dial': '+229'},
    {'code': 'SL', 'name': 'Sierra Leone 🇸🇱', 'dial': '+232'},
    {'code': 'LR', 'name': 'Liberia 🇱🇷', 'dial': '+231'},
    {'code': 'GM', 'name': 'Gambie 🇬🇲', 'dial': '+220'},
    {'code': 'GW', 'name': 'Guinée-Bissau 🇬🇼', 'dial': '+245'},
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _avatarScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _avatarController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    _avatarController.forward().then((_) => _avatarController.reverse());

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked != null) {
      // Sauvegarder l'image
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(picked.path).copy(path);

      setState(() => _avatarImage = savedImage);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showError('Veuillez accepter les conditions d\'utilisation');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _selectedCountry,
        password: _passwordController.text,
        avatarPath: _avatarImage?.path,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showError(result['message'] ?? 'Erreur lors de l\'inscription');
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

                    const SizedBox(height: 24),

                    // Avatar picker
                    _buildAvatarPicker(),

                    const SizedBox(height: 32),

                    // Formulaire
                    _buildForm(),

                    const SizedBox(height: 24),

                    // Switch entreprise
                    _buildEnterpriseSwitch(),

                    const SizedBox(height: 16),

                    // Terms
                    _buildTermsCheckbox(),

                    const SizedBox(height: 32),

                    // Bouton inscription
                    NeonButton(
                      text: 'CRÉER MON COMPTE',
                      icon: Icons.person_add_alt_1_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ),

                    const SizedBox(height: 24),

                    // Lien connexion
                    _buildLoginLink(),

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppGradients.neonRainbow.createShader(bounds),
                child: Text(
                  'Créer un compte',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Rejoignez BARRY WI-FI',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedBuilder(
        animation: _avatarController,
        builder: (context, child) {
          return Transform.scale(
            scale: _avatarScale.value,
            child: Stack(
              children: [
                // Avatar container
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
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkCard,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _avatarImage != null
                            ? Image.file(
                                _avatarImage!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.textMuted,
                              ),
                      ),
                    ),
                  ),
                ),

                // Badge caméra
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neonViolet,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkCard,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonViolet.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
            // Prénom
            GlassInputField(
              label: 'Prénom',
              hint: 'Votre prénom',
              controller: _firstNameController,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre prénom';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Nom
            GlassInputField(
              label: 'Nom de famille',
              hint: 'Votre nom',
              controller: _lastNameController,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Sélecteur de pays
            _buildCountrySelector(),

            const SizedBox(height: 20),

            // Téléphone
            GlassInputField(
              label: 'Téléphone',
              hint: 'XXX XXX XXX',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre téléphone';
                }
                if (value.length < 8) {
                  return 'Numéro invalide';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Mot de passe
            GlassInputField(
              label: 'Mot de passe',
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
              controller: _confirmPasswordController,
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

  Widget _buildCountrySelector() {
    final selectedCountryData = _countries.firstWhere(
      (c) => c['code'] == _selectedCountry,
      orElse: () => _countries.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pays',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showCountryPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  color: AppColors.textMuted,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCountryData['name']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  selectedCountryData['dial']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sélectionner un pays',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = country['code'] == _selectedCountry;

                  return ListTile(
                    onTap: () {
                      setState(() => _selectedCountry = country['code']!);
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.neonViolet.withOpacity(0.2)
                            : AppColors.darkBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          country['name']!.split(' ').last,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      country['name']!.split(' ').first,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isSelected
                            ? AppColors.neonViolet
                            : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    subtitle: Text(
                      country['dial']!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppColors.neonViolet)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterpriseSwitch() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.neonViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.business_rounded,
              color: _isEnterprise ? AppColors.neonViolet : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compte Entreprise',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Multi-appareils, forfaits premium',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Switch iOS style
          GestureDetector(
            onTap: () => setState(() => _isEnterprise = !_isEnterprise),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                gradient: _isEnterprise
                    ? AppGradients.neonVioletGradient
                    : null,
                color: _isEnterprise ? null : AppColors.darkBorder,
                boxShadow: _isEnterprise
                    ? [
                        BoxShadow(
                          color: AppColors.neonViolet.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    _isEnterprise ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: _acceptTerms ? AppGradients.neonVioletGradient : null,
              color: _acceptTerms ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _acceptTerms ? Colors.transparent : AppColors.textMuted,
                width: 2,
              ),
            ),
            child: _acceptTerms
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'J\'accepte les '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/terms'),
                      child: Text(
                        'conditions d\'utilisation',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.modernTurquoise,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' et la '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/privacy'),
                      child: Text(
                        'politique de confidentialité',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.modernTurquoise,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Déjà un compte ?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Se connecter',
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
