import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_strings.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> getMenu() async {
    final response = await http.get(Uri.parse('\$_baseUrl/menu'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addItem(MenuItemModel item, String token) async {
    final response = await http.post(
      Uri.parse('\$_baseUrl/menu'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \$token',
      },
      body: jsonEncode(item.toJson()),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateItem(MenuItemModel item, String token) async {
    final response = await http.put(
      Uri.parse('\$_baseUrl/menu/\${item.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer \$token',
      },
      body: jsonEncode(item.toJson()),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteItem(int id, String token) async {
    final response = await http.delete(
      Uri.parse('\$_baseUrl/menu/\$id'),
      headers: {
        'Authorization': 'Bearer \$token',
      },
    );
    return jsonDecode(response.body);
  }
}
