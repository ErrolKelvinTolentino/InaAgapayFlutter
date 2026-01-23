import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://inaagapay.alwaysdata.net/";

class VerifyService {
  static Future<bool> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}verify.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (!response.body.trim().startsWith('{')) {
        return false;
      }

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
