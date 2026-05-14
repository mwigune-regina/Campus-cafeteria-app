import 'dart:convert';
import '../core/constants/app_strings.dart';
import '_http_client.dart';

class WalletService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> getBalance(String token) {
    return ApiClient.get(
      Uri.parse('$_baseUrl/wallet/balance'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> topUp(double amount, String paymentMethod, String token) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/wallet/top-up'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount, 'payment_method': paymentMethod}),
    );
  }

  Future<Map<String, dynamic>> getTransactions(String token) {
    return ApiClient.get(
      Uri.parse('$_baseUrl/wallet/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
