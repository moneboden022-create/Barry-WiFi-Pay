// lib/models/session_model.dart
class SessionModel {
  final String id;
  final String user;
  final String device;
  final String mac;
  final String createdAt;
  final bool active;

  SessionModel({
    required this.id,
    required this.user,
    required this.device,
    required this.mac,
    required this.createdAt,
    required this.active,
  });

  factory SessionModel.fromJson(Map<String, dynamic> j) {
    return SessionModel(
      id: j['id']?.toString() ?? '',
      user: j['user']?.toString() ?? '',
      device: j['device']?.toString() ?? '',
      mac: j['mac']?.toString() ?? '',
      createdAt: j['created_at']?.toString() ?? '',
      active: j['active'] == true,
    );
  }
}
