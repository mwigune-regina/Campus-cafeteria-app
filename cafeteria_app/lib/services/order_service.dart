import 'dart:convert';
import '../core/constants/app_strings.dart';
import '../models/cart_item_model.dart';
import '_http_client.dart';

class OrderService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> placeOrder(List<CartItemModel> items, double total, String token) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'items': items.map((i) => i.toJson()).toList(),
        'total_amount': total,
      }),
    );
  }

  Future<Map<String, dynamic>> getMyOrders(String token) {
    return ApiClient.get(
      Uri.parse('$_baseUrl/orders/my'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> verifyQR(String qrToken, String token) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/orders/verify-qr'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'token': qrToken}),
    );
  }

  Future<Map<String, dynamic>> getAllOrders(String token, {String? status}) {
    final uri = Uri.parse('$_baseUrl/orders${status != null ? '?status=$status' : ''}');
    return ApiClient.get(uri, headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> getQueue(String token) {
    return ApiClient.get(
      Uri.parse('$_baseUrl/orders/queue'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> getOrderById(int id, String token) {
    return ApiClient.get(
      Uri.parse('$_baseUrl/orders/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> updateStatus(int id, String status, String token) {
    return ApiClient.patch(
      Uri.parse('$_baseUrl/orders/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
  }
}
