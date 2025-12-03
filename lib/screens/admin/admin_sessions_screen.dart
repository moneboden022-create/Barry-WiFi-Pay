// lib/screens/admin/admin_sessions_screen.dart
// 🔐 BARRY WI-FI - Gestion des Sessions Admin

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/admin_service.dart';
import '../../services/auth_service.dart';

class AdminSessionsScreen extends StatefulWidget {
  const AdminSessionsScreen({super.key});

  @override
  State<AdminSessionsScreen> createState() => _AdminSessionsScreenState();
}

class _AdminSessionsScreenState extends State<AdminSessionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final result = await AdminService.getAllAdminSessions();
      if (result['success'] == true) {
        setState(() {
          _sessions = List<Map<String, dynamic>>.from(result['sessions'] ?? []);
          _isLoading = false;
        });
      } else {
        _showError(result['message'] ?? 'Erreur lors du chargement des sessions');
      }
    } catch (e) {
      _showError('Erreur de connexion au serveur');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSession(int sessionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment déconnecter cette session ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await AdminService.deleteAdminSession(sessionId);
      if (result['success'] == true) {
        _showSuccess('Session supprimée avec succès');
        _loadSessions();
      } else {
        _showError(result['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      _showError('Erreur de connexion au serveur');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions Admin'),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
      ),
      backgroundColor: AppColors.darkBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSessions,
              child: _sessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.devices, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune session active',
                            style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _sessions.length,
                      itemBuilder: (context, index) {
                        final session = _sessions[index];
                        return Card(
                          color: AppColors.cardBackground,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Icon(
                              Icons.devices,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              session['admin_name'] ?? 'Admin inconnu',
                              style: AppTextStyles.bodyMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (session['admin_phone'] != null)
                                  Text(
                                    'Téléphone: ${session['admin_phone']}',
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                  ),
                                Text(
                                  'Appareil: ${session['device_id'] ?? 'N/A'}',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                ),
                                Text(
                                  'IP: ${session['ip'] ?? 'N/A'}',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                ),
                                Text(
                                  'Créé: ${_formatDate(session['created_at'])}',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                ),
                                Text(
                                  'Expire: ${_formatDate(session['expires_at'])}',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                ),
                                if (session['user_agent'] != null)
                                  Text(
                                    'UA: ${session['user_agent'].toString().substring(0, session['user_agent'].toString().length > 50 ? 50 : session['user_agent'].toString().length)}...',
                                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSession(session['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

