// lib/models/admin_models.dart
// 🔐 BARRY WI-FI - Modèles Admin 5G

class AdminUser {
  final String id;
  final String firstname;
  final String lastname;
  final String phone;
  final String email;
  final String role;
  final bool active;

  AdminUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.email,
    required this.role,
    required this.active,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json["id"].toString(),
      firstname: json["firstname"]?.toString() ?? json["first_name"]?.toString() ?? "",
      lastname: json["lastname"]?.toString() ?? json["last_name"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? json["phone_number"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      role: json["role"]?.toString() ?? "user",
      active: json["active"] == true || json["is_active"] == true,
    );
  }

  String get fullName => "$firstname $lastname".trim();
}

// ================= SESSION ===================

class Session {
  final String ip;
  final String device;
  final DateTime? createdAt;
  final String? userId;
  final bool isActive;

  Session({
    required this.ip,
    required this.device,
    this.createdAt,
    this.userId,
    this.isActive = true,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      ip: json["ip"]?.toString() ?? "unknown",
      device: json["device"]?.toString() ?? json["device_name"]?.toString() ?? "unknown",
      createdAt: json["created_at"] != null 
          ? DateTime.tryParse(json["created_at"].toString())
          : json["start_at"] != null
              ? DateTime.tryParse(json["start_at"].toString())
              : null,
      userId: json["user_id"]?.toString(),
      isActive: json["is_active"] ?? json["active"] ?? true,
    );
  }

  String get formattedDate {
    if (createdAt == null) return "-";
    return "${createdAt!.day}/${createdAt!.month}/${createdAt!.year} ${createdAt!.hour}:${createdAt!.minute.toString().padLeft(2, '0')}";
  }
}

// ================= STATS ===================

class Stat {
  final String name;
  final String title;
  final int value;
  final String? icon;
  final double? change; // % de changement

  Stat({
    String? name,
    required this.title,
    required this.value,
    this.icon,
    this.change,
  }) : name = name ?? title;

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      name: json["name"]?.toString() ?? json["title"]?.toString() ?? "",
      title: json["title"]?.toString() ?? json["name"]?.toString() ?? "",
      value: json["value"] is int
          ? json["value"]
          : int.tryParse(json["value"].toString()) ?? 0,
      icon: json["icon"]?.toString(),
      change: json["change"] is num ? json["change"].toDouble() : null,
    );
  }

  String get formattedValue {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(1)}K";
    }
    return value.toString();
  }
}

// ================= VOUCHER ADMIN ===================

class AdminVoucher {
  final int id;
  final String code;
  final String type;
  final int durationMinutes;
  final int maxDevices;
  final String status;
  final DateTime? createdAt;
  final DateTime? usedAt;
  final String? usedBy;

  AdminVoucher({
    required this.id,
    required this.code,
    required this.type,
    required this.durationMinutes,
    required this.maxDevices,
    required this.status,
    this.createdAt,
    this.usedAt,
    this.usedBy,
  });

  factory AdminVoucher.fromJson(Map<String, dynamic> json) {
    return AdminVoucher(
      id: json["id"] ?? 0,
      code: json["code"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "individual",
      durationMinutes: json["duration_minutes"] ?? 60,
      maxDevices: json["max_devices"] ?? 1,
      status: json["status"]?.toString() ?? "active",
      createdAt: json["created_at"] != null 
          ? DateTime.tryParse(json["created_at"].toString())
          : null,
      usedAt: json["used_at"] != null 
          ? DateTime.tryParse(json["used_at"].toString())
          : null,
      usedBy: json["used_by"]?.toString(),
    );
  }

  bool get isUsed => status == "used";
  bool get isExpired => status == "expired";
  bool get isActive => status == "active";

  String get formattedDuration {
    if (durationMinutes >= 24 * 60) {
      final days = durationMinutes ~/ (24 * 60);
      return "$days jour${days > 1 ? 's' : ''}";
    } else if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      return "$hours heure${hours > 1 ? 's' : ''}";
    }
    return "$durationMinutes min";
  }
}

// ================= DEVICE ADMIN ===================

class AdminDevice {
  final int id;
  final String deviceId;
  final String? deviceName;
  final String? macAddress;
  final int userId;
  final bool isBlocked;
  final DateTime? lastSeen;

  AdminDevice({
    required this.id,
    required this.deviceId,
    this.deviceName,
    this.macAddress,
    required this.userId,
    this.isBlocked = false,
    this.lastSeen,
  });

  factory AdminDevice.fromJson(Map<String, dynamic> json) {
    return AdminDevice(
      id: json["id"] ?? 0,
      deviceId: json["device_id"]?.toString() ?? "",
      deviceName: json["device_name"]?.toString(),
      macAddress: json["mac_address"]?.toString(),
      userId: json["user_id"] ?? 0,
      isBlocked: json["is_blocked"] ?? false,
      lastSeen: json["last_seen"] != null 
          ? DateTime.tryParse(json["last_seen"].toString())
          : null,
    );
  }
}
