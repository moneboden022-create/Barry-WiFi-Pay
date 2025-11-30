// lib/models/connection_model.dart

class ConnectionModel {
  final String ip;
  final String device;

  ConnectionModel({
    required this.ip,
    required this.device,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      ip: json["ip"]?.toString() ?? "unknown",
      device: json["device"]?.toString() ?? "unknown",
    );
  }
}
