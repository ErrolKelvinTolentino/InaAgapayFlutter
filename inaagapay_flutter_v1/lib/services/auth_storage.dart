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

  // NEW: Save mother ID
  static Future<void> saveMotherId(int motherId) async {
    await _storage.write(key: 'mother_id', value: motherId.toString());
  }

  // NEW: Get mother ID
  static Future<int?> getMotherId() async {
    final value = await _storage.read(key: 'mother_id');
    if (value == null) return null;
    return int.tryParse(value);
  }

  // NEW: Clear mother ID
  static Future<void> clearMotherId() async {
    await _storage.delete(key: 'mother_id');
  }

  // NEW: Clear all auth data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}