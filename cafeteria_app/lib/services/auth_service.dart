import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_strings.dart';
import '../models/user_model.dart';

class AuthService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('\$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('\$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('\$_baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }
}
