import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  // 🔐 Secure storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save token after login
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Read token for API requests
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Remove token on logout
  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Optional helper
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
