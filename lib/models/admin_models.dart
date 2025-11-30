// lib/models/admin_models.dart

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
      firstname: json["firstname"]?.toString() ?? "",
      lastname: json["lastname"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      role: json["role"]?.toString() ?? "",
      active: json["active"] == true,
    );
  }
}

// ================= SESSION ===================

class Session {
  final String ip;
  final String device;

  Session({
    required this.ip,
    required this.device,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      ip: json["ip"]?.toString() ?? "unknown",
      device: json["device"]?.toString() ?? "unknown",
    );
  }
}

// ================= STATS ===================

class Stat {
  final String title;
  final int value;

  Stat({
    required this.title,
    required this.value,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      title: json["title"]?.toString() ?? "",
      value: json["value"] is int
          ? json["value"]
          : int.tryParse(json["value"].toString()) ?? 0,
    );
  }
}
