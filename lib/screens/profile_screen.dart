// lib/profile_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController();

  bool _saving = false;
  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Charge les infos depuis SharedPreferences
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _first.text = prefs.getString('firstName') ?? '';
      _last.text = prefs.getString('lastName') ?? '';
      _phone.text = prefs.getString('phone') ?? '';
      _country.text = prefs.getString('country') ?? 'Guinée';
      _localImagePath = prefs.getString('avatar_path');
    });
  }

  /// Sauvegarde texte + chemin avatar
  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _first.text);
    await prefs.setString('lastName', _last.text);
    await prefs.setString('phone', _phone.text);
    await prefs.setString('country', _country.text);
    if (_localImagePath != null) await prefs.setString('avatar_path', _localImagePath!);
    // Simuler un petit délai (API)
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil enregistré')));
  }

  /// Ouvre un modal pour choix Camera / Galerie / Supprimer
  Future<void> _onChangeAvatarPressed() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_localImagePath != null) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeAvatar();
                },
              )
            ],
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }

  /// Récupère l'image (gallery/camera), la copie localement et sauvegarde le chemin.
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Sur le web, ImageSource.camera peut ne pas être supporté.
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );
      if (picked == null) return;

      // Si on est sur le web, on ne peut pas utiliser File system de la même manière.
      if (kIsWeb) {
        // Pour web, on conserve le path (qui sera un 'blob' non persisté) — better: envoyer au serveur.
        setState(() => _localImagePath = picked.path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_path', picked.path);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image sélectionnée (Web)')));
        return;
      }

      // Copie le fichier dans le répertoire d'app pour persistance
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

      // Optionnel : supprimer l'ancienne image si existante (pour économiser l'espace)
      if (_localImagePath != null) {
        try {
          final old = File(_localImagePath!);
          if (await old.exists()) await old.delete();
        } catch (_) {}
      }

      setState(() => _localImagePath = savedFile.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', savedFile.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo de profil mise à jour')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur image : $e')));
    }
  }

  /// Supprime l'avatar (local + SharedPreferences)
  Future<void> _removeAvatar() async {
    if (_localImagePath == null) return;
    try {
      if (!kIsWeb) {
        final file = File(_localImagePath!);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('avatar_path');
    setState(() => _localImagePath = null);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo supprimée')));
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = "${_first.text} ${_last.text}".trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            // Banner style (Facebook-like) + avatar overlap
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Positioned(
                  bottom: -48,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _onChangeAvatarPressed,
                        child: Hero(
                          tag: 'drawer-avatar',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                            ),
                            child: CircleAvatar(
                              radius: 54,
                              backgroundColor: theme.cardColor,
                              backgroundImage: (_localImagePath != null && !kIsWeb) ? FileImage(File(_localImagePath!)) as ImageProvider? : null,
                              child: (_localImagePath == null)
                                  ? const Icon(Icons.person, size: 48, color: Colors.grey)
                                  : (kIsWeb ? null : null),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(fullName.isEmpty ? 'Utilisateur BARRY WI-FI' : fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _onChangeAvatarPressed,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Modifier la photo'),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 70),

            // Card with fields
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildField(label: 'Prénom', controller: _first),
                    const SizedBox(height: 8),
                    _buildField(label: 'Nom', controller: _last),
                    const SizedBox(height: 8),
                    _buildField(label: 'Téléphone', controller: _phone, inputType: TextInputType.phone),
                    const SizedBox(height: 8),
                    _buildField(label: 'Pays', controller: _country),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _saving
                            ? ElevatedButton(
                                key: const ValueKey('loading'),
                                style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                                onPressed: null,
                                child: const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              )
                            : ElevatedButton.icon(
                                key: const ValueKey('save'),
                                icon: const Icon(Icons.save),
                                label: const Text('Enregistrer le profil'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _saveProfile,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Type de compte'),
              subtitle: const Text('Individuel (démo)'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, TextInputType? inputType}) {
    return TextField(
      controller: controller,
      keyboardType: inputType ?? TextInputType.text,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      onChanged: (_) => setState(() {}), // update fullName live
    );
  }
}
