// lib/screens/profile/profile_screen.dart
// 👤 BARRY WI-FI - Profil Utilisateur Premium 5G

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/neon_button.dart';
import '../../core/widgets/input_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _avatarController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _avatarPath;
  bool _isEditing = false;
  bool _isSaving = false;

  // Stats utilisateur
  int _totalConnections = 0;
  String _totalDataUsed = '0 GB';
  String _memberSince = '';
  String _accountType = 'Particulier';

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

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString("avatar_path");
      _nameController.text = prefs.getString("user_name") ?? "";
      _emailController.text = prefs.getString("user_email") ?? "";
      _phoneController.text = prefs.getString("user_phone") ?? "";
      _totalConnections = prefs.getInt("total_connections") ?? 45;
      _totalDataUsed = prefs.getString("total_data") ?? "12.5 GB";
      _memberSince = prefs.getString("member_since") ?? "Janvier 2024";
      _accountType = prefs.getBool("is_enterprise") == true
          ? "Entreprise"
          : "Particulier";
    });
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
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(picked.path).copy(path);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("avatar_path", path);

      setState(() => _avatarPath = savedImage.path);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_name", _nameController.text);
      await prefs.setString("user_email", _emailController.text);
      await prefs.setString("user_phone", _phoneController.text);

      _showMessage('Profil mis à jour !', AppColors.success);
      setState(() => _isEditing = false);
    } catch (e) {
      _showMessage('Erreur lors de la sauvegarde', AppColors.error);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.success ? Icons.check_circle : Icons.error,
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
  void dispose() {
    _fadeController.dispose();
    _avatarController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildAvatarSection()),
                SliverToBoxAdapter(child: _buildStats()),
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildInfoSection(),
                      const SizedBox(height: 20),
                      _buildActionsSection(),
                      const SizedBox(height: 40),
                    ]),
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
                    'Mon Profil',
                    style: AppTextStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  _accountType,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isEditing = !_isEditing),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isEditing
                    ? AppColors.error.withOpacity(0.15)
                    : AppColors.neonViolet.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: _isEditing ? AppColors.error : AppColors.neonViolet,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isEditing ? _pickImage : null,
            child: AnimatedBuilder(
              animation: _avatarController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_avatarController.value * 0.1),
                  child: Stack(
                    children: [
                      // Glow effect
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.neonViolet.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Avatar
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.neonVioletGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonViolet.withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.darkCard,
                              ),
                              child: ClipOval(
                                child: _avatarPath != null
                                    ? Image.file(
                                        File(_avatarPath!),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.textMuted,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Edit badge
                      if (_isEditing)
                        Positioned(
                          bottom: 10,
                          right: 10,
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
                            ),
                            child: const Icon(
                              Icons.camera_alt,
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
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isEmpty ? 'Utilisateur' : _nameController.text,
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Membre depuis $_memberSince',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.wifi,
              label: 'Connexions',
              value: '$_totalConnections',
              color: AppColors.neonGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.data_usage,
              label: 'Données',
              value: _totalDataUsed,
              color: AppColors.modernTurquoise,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars,
              label: 'Niveau',
              value: 'Pro',
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
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

  Widget _buildInfoSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations personnelles',
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          if (_isEditing) ...[
            GlassInputField(
              label: 'Nom complet',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            GlassInputField(
              label: 'Email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            GlassInputField(
              label: 'Téléphone',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            NeonButton(
              text: 'ENREGISTRER',
              icon: Icons.save,
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
          ] else ...[
            _buildInfoRow(Icons.person_outline, 'Nom', _nameController.text),
            const Divider(color: AppColors.darkBorder, height: 24),
            _buildInfoRow(Icons.email_outlined, 'Email', _emailController.text),
            const Divider(color: AppColors.darkBorder, height: 24),
            _buildInfoRow(Icons.phone_outlined, 'Téléphone', _phoneController.text),
            const Divider(color: AppColors.darkBorder, height: 24),
            _buildInfoRow(Icons.business, 'Type de compte', _accountType),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.neonViolet.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.neonViolet, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value.isEmpty ? 'Non renseigné' : value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      children: [
        _buildActionItem(
          icon: Icons.lock_outline,
          title: 'Changer le mot de passe',
          color: AppColors.modernTurquoise,
          onTap: () => Navigator.pushNamed(context, '/reset'),
        ),
        const SizedBox(height: 12),
        _buildActionItem(
          icon: Icons.history,
          title: 'Historique des connexions',
          color: AppColors.neonGreen,
          onTap: () => Navigator.pushNamed(context, '/connections'),
        ),
        const SizedBox(height: 12),
        _buildActionItem(
          icon: Icons.help_outline,
          title: 'Aide & Support',
          color: AppColors.neonViolet,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildActionItem(
          icon: Icons.delete_outline,
          title: 'Supprimer mon compte',
          color: AppColors.error,
          onTap: () => _showDeleteConfirmation(),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
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
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: color.withOpacity(0.5),
            size: 18,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Supprimer le compte',
          style: AppTextStyles.h6.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Supprimer le compte
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

