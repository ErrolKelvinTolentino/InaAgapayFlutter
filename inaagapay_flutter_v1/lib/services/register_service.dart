import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "https://inaagapay.alwaysdata.net/api/auth/";

class RegisterService {
  static Future<bool> registerMother({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}register.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      // 🔴 IMPORTANT: Check response BEFORE decoding
      if (response.statusCode != 200) {
        print('HTTP ERROR: ${response.statusCode}');
        print('BODY: ${response.body}');
        return false;
      }

      // 🔴 Guard against HTML / empty responses
      if (response.body.isEmpty || !response.body.trim().startsWith('{')) {
        print('INVALID RESPONSE (NOT JSON)');
        print(response.body);
        return false;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      return data['success'] == true;
    } catch (e) {
      print('REGISTER ERROR: $e');
      return false;
    }
  }
}
