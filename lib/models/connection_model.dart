// lib/models/connection_model.dart
// 📡 BARRY WI-FI - Modèle de Connexion 5G

class ConnectionModel {
  final int id;
  final String ip;
  final int userId;
  final String deviceId;
  final String? voucherCode;
  final DateTime startAt;
  final DateTime? endAt;
  final bool success;
  final String? macAddress;
  final String? deviceName;
  final int? dataUsed; // en bytes
  final bool isBlocked;

  ConnectionModel({
    required this.id,
    required this.ip,
    required this.userId,
    required this.deviceId,
    this.voucherCode,
    required this.startAt,
    this.endAt,
    this.success = true,
    this.macAddress,
    this.deviceName,
    this.dataUsed,
    this.isBlocked = false,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] ?? 0,
      ip: json['ip'] ?? '',
      userId: json['user_id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      voucherCode: json['voucher_code'],
      startAt: json['start_at'] != null 
          ? DateTime.parse(json['start_at']) 
          : DateTime.now(),
      endAt: json['end_at'] != null 
          ? DateTime.parse(json['end_at']) 
          : null,
      success: json['success'] ?? true,
      macAddress: json['mac_address'],
      deviceName: json['device_name'],
      dataUsed: json['data_used'],
      isBlocked: json['is_blocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ip': ip,
      'user_id': userId,
      'device_id': deviceId,
      'voucher_code': voucherCode,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'success': success,
      'mac_address': macAddress,
      'device_name': deviceName,
      'data_used': dataUsed,
      'is_blocked': isBlocked,
    };
  }

  /// Durée de connexion
  Duration get duration {
    final end = endAt ?? DateTime.now();
    return end.difference(startAt);
  }

  /// Durée formatée
  String get formattedDuration {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}m';
    } else {
      return '${d.inSeconds}s';
    }
  }

  /// Data utilisée formatée
  String get formattedDataUsed {
    if (dataUsed == null) return '0 MB';
    final mb = dataUsed! / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(1)} MB';
  }
}

