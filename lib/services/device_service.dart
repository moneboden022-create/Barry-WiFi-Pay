// lib/services/device_service.dart
// 📱 BARRY WI-FI - Service Device 5G

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _deviceKey = 'device_id';

/// Obtient l'identifiant unique de l'appareil
Future<String> getDeviceId() async {
  // Vérifier si on a déjà un ID stocké
  final existing = await _storage.read(key: _deviceKey);
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }

  // Générer un nouvel ID basé sur les infos de l'appareil
  final info = DeviceInfoPlugin();
  String deviceId;

  try {
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      // Utiliser une combinaison de plusieurs identifiants
      deviceId = '${android.model}-${android.id}-${android.fingerprint.hashCode}';
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      deviceId = ios.identifierForVendor ?? _generateUUID();
    } else if (Platform.isWindows) {
      final windows = await info.windowsInfo;
      deviceId = windows.deviceId;
    } else if (Platform.isLinux) {
      final linux = await info.linuxInfo;
      deviceId = linux.machineId ?? _generateUUID();
    } else if (Platform.isMacOS) {
      final mac = await info.macOsInfo;
      deviceId = mac.systemGUID ?? _generateUUID();
    } else {
      deviceId = _generateUUID();
    }
  } catch (_) {
    deviceId = _generateUUID();
  }

  // Sauvegarder l'ID
  await _storage.write(key: _deviceKey, value: deviceId);
  return deviceId;
}

/// Génère un UUID simple
String _generateUUID() {
  final now = DateTime.now();
  final random = now.millisecondsSinceEpoch.toString();
  return 'bwifi-${random.hashCode.abs().toRadixString(16)}-${now.microsecond.toRadixString(16)}';
}

/// Obtient les informations de l'appareil
Future<Map<String, dynamic>> getDeviceInfo() async {
  final info = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return {
        'platform': 'Android',
        'model': android.model,
        'brand': android.brand,
        'version': android.version.release,
        'sdk': android.version.sdkInt,
        'manufacturer': android.manufacturer,
        'device': android.device,
      };
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return {
        'platform': 'iOS',
        'model': ios.model,
        'name': ios.name,
        'version': ios.systemVersion,
        'device': ios.utsname.machine,
      };
    } else if (Platform.isWindows) {
      final windows = await info.windowsInfo;
      return {
        'platform': 'Windows',
        'name': windows.computerName,
        'version': '${windows.majorVersion}.${windows.minorVersion}',
        'cores': windows.numberOfCores,
        'memory': windows.systemMemoryInMegabytes,
      };
    } else if (Platform.isMacOS) {
      final mac = await info.macOsInfo;
      return {
        'platform': 'macOS',
        'model': mac.model,
        'name': mac.computerName,
        'version': mac.osRelease,
        'arch': mac.arch,
      };
    } else if (Platform.isLinux) {
      final linux = await info.linuxInfo;
      return {
        'platform': 'Linux',
        'name': linux.name,
        'version': linux.version,
        'id': linux.id,
      };
    }
  } catch (_) {}

  return {
    'platform': Platform.operatingSystem,
    'version': Platform.operatingSystemVersion,
  };
}

/// Obtient le nom de l'appareil pour l'affichage
Future<String> getDeviceName() async {
  final info = await getDeviceInfo();
  final platform = info['platform'] ?? 'Unknown';
  final model = info['model'] ?? info['name'] ?? '';
  
  if (model.isNotEmpty) {
    return '$platform - $model';
  }
  return platform;
}
