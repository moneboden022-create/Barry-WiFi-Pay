// lib/screens/register_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path; // pour basename
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // === Controllers ===
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final countryController = TextEditingController(text: "GN");
  final passwordController = TextEditingController();
  bool isBusiness = false;

  // === Image picker ===
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _loading = false;

  // === BACKEND BASE URL ===
  // adapte si ton backend est à une autre adresse
  final String baseUrl = "http://127.0.0.1:8000"; // <-- assure-toi que c'est accessible depuis ton appareil

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    countryController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _pickedImage = picked);
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _pickedImage = picked);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choisir depuis la galerie"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Prendre une photo"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
              if (_pickedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Retirer la photo", style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _pickedImage = null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final country = countryController.text.trim();
    final password = passwordController.text;

    if (first.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Remplis au moins le prénom, téléphone et mot de passe")));
      return;
    }

    setState(() => _loading = true);

    try {
      // Endpoint complet : /api/auth/register (main.py inclut router with prefix "/api" + auth router "/auth")
      final uri = Uri.parse("$baseUrl/api/auth/register");
      final request = http.MultipartRequest('POST', uri);

      // Champs FormData
      request.fields['first_name'] = first;
      request.fields['last_name'] = last;
      request.fields['phone_number'] = phone;
      request.fields['country'] = country.isEmpty ? 'GN' : country;
      request.fields['password'] = password;
      request.fields['isBusiness'] = isBusiness ? 'true' : 'false';

      // OPTIONAL: add device id header (backend checks for devices), here random or you can use a persistent id
      request.headers['X-Device-ID'] = DateTime.now().millisecondsSinceEpoch.toString();

      // Fichier avatar si present
      if (_pickedImage != null) {
        if (kIsWeb) {
          // Web : lire en bytes
          final bytes = await _pickedImage!.readAsBytes();
          final filename = path.basename(_pickedImage!.name);
          final multipartFile = http.MultipartFile.fromBytes('avatar', bytes, filename: filename);
          request.files.add(multipartFile);
        } else {
          // Mobile: ajout depuis path
          final filePath = _pickedImage!.path;
          // Pour s'assurer que le fichier existe et éviter locked file on some platforms, on peut copier dans app dir (optionnel)
          // Ici on utilise directement le path
          final file = await http.MultipartFile.fromPath('avatar', filePath, filename: path.basename(filePath));
          request.files.add(file);
        }
      }

      // Envoi
      final streamedRes = await request.send();
      final res = await http.Response.fromStream(streamedRes);

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Succès — backend retourne le UserOut JSON (voir schemas)
        // Tu peux parser et enregistrer token si backend retourne tokens au register
        final data = jsonDecode(res.body);
        // Optionnel : si ton backend retournait un token, tu pourrais le stocker en SharedPreferences
        // Exemple:
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('access_token', data['access_token']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription réussie !')));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Erreur — afficher message du serveur si disponible
        String message = 'Erreur inscription (${res.statusCode})';
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['detail'] != null) message = body['detail'].toString();
          else if (body is Map && body['message'] != null) message = body['message'].toString();
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur réseau: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildTextField(TextEditingController c, String label, {TextInputType keyboard = TextInputType.text, IconData? icon}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E81CE), Color(0xFFB088FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: 520, // limite la largeur sur grands écrans
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.98),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0,6))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // banner + avatar
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(Icons.person_add, size: 54, color: Color(0xFF0B6EDC)),
                        const SizedBox(height: 8),
                        const Text("Créer un compte", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        // avatar preview
                        GestureDetector(
                          onTap: _showImageOptions,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: (_pickedImage != null && !kIsWeb) ? FileImage(File(_pickedImage!.path)) as ImageProvider : null,
                            child: (_pickedImage == null)
                                ? const Icon(Icons.camera_alt, size: 36, color: Colors.grey)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _showImageOptions, child: const Text("Ajouter une photo (facultatif)"))
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildTextField(firstNameController, "Prénom", icon: Icons.badge),
                  const SizedBox(height: 10),
                  _buildTextField(lastNameController, "Nom", icon: Icons.badge_outlined),
                  const SizedBox(height: 10),
                  _buildTextField(phoneController, "Téléphone", keyboard: TextInputType.phone, icon: Icons.phone),
                  const SizedBox(height: 10),
                  _buildTextField(countryController, "Pays (ex : GN)", icon: Icons.flag),
                  const SizedBox(height: 10),
                  _buildTextField(passwordController, "Mot de passe", icon: Icons.lock),
                  const SizedBox(height: 10),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Compte entreprise ?"),
                    value: isBusiness,
                    onChanged: (v) => setState(() => isBusiness = v),
                  ),

                  const SizedBox(height: 10),

                  _loading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B6EDC),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _submit,
                            child: const Text("Créer le compte"),
                          ),
                        ),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text("J'ai déjà un compte → Connexion"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
