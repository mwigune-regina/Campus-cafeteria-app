import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_strings.dart';
import '../models/cart_item_model.dart';

class OrderService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> placeOrder(List<CartItemModel> items, double total, String token) async {
    final response = await http.post(
      Uri.parse('\$_baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \$token',
      },
      body: jsonEncode({
        'items': items.map((i) => i.toJson()).toList(),
        'total_amount': total,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMyOrders(String token) async {
    final response = await http.get(
      Uri.parse('\$_baseUrl/orders/my'),
      headers: {'Authorization': 'Bearer \$token'},
    );
    return jsonDecode(response.body);
  }
}
