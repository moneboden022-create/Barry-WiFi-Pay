import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static final _secure = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _secure.write(key: "auth_token", value: token);
  }

  static Future<String?> loadToken() async {
    return await _secure.read(key: "auth_token");
  }

  static Future<void> removeToken() async {
    await _secure.delete(key: "auth_token");
  }
}
