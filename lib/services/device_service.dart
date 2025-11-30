import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();
const _deviceKey = 'device_id';

Future<String> getDeviceId() async {
  final existing = await _storage.read(key: _deviceKey);
  if (existing != null) return existing;

  // essaye d'utiliser un identifiant matériel si possible
  final info = DeviceInfoPlugin();
  try {
    final android = await info.androidInfo;
    final id = android.androidId; // parfois null
    if (id != null && id.isNotEmpty) {
      await _storage.write(key: _deviceKey, value: id);
      return id;
    }
  } catch (_) {}

  final uuid = Uuid().v4();
  await _storage.write(key: _deviceKey, value: uuid);
  return uuid;
}
