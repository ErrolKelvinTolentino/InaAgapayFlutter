import 'dart:async';

/// Result object returned by verification
class VerifyResult {
  final bool success;
  final bool isLinked;

  VerifyResult({required this.success, required this.isLinked});
}

class VerifyService {
  /// Verifies the code and tells if the account is already linked
  static Future<VerifyResult> verifyCodeWithStatus({
    required String email,
    required String code,
  }) async {
    // ⏳ Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // 🧪 MOCK LOGIC (replace with real API later)
    // 654321 → existing/linked account
    if (code == '654321') {
      return VerifyResult(success: true, isLinked: true);
    }

    // 123456 → new valid account
    if (code == '123456') {
      return VerifyResult(success: true, isLinked: false);
    }

    // ❌ Invalid code
    return VerifyResult(success: false, isLinked: false);
  }

  /// OPTIONAL: keep your old method if other screens use it
  static Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '123456' || code == '654321';
  }
}
