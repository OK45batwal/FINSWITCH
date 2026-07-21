import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) =>
      _storage.write(key: 'auth_token', value: token);

  static Future<String?> getToken() =>
      _storage.read(key: 'auth_token');

  static Future<void> clearAll() =>
      _storage.deleteAll();
}
