import 'dart:convert';
import '../core/constants/app_strings.dart';
import '_http_client.dart';

class AuthService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> login(String username, String password) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, String role) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
  }

  Future<Map<String, dynamic>> forgotPassword(String email) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/auth/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
  }

  Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'password': newPassword,
      }),
    );
  }
}
