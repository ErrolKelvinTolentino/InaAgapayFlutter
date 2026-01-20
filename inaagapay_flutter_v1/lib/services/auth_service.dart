import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = "https://inaagapay.alwaysdata.net/";

class AuthService {
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('${baseUrl}login.php');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AuthResponse.fromJson(data);
      } else {
        return AuthResponse(
          success: false,
          message: 'Server error (${response.statusCode})',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Connection failed. Please try again.',
      );
    }
  }
}

/* 🔽 PUT AuthResponse HERE (BOTTOM OF FILE) 🔽 */

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      user: json['user'],
    );
  }
}
