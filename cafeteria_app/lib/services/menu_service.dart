import 'dart:convert';
import '../core/constants/app_strings.dart';
import '../models/menu_item_model.dart';
import '_http_client.dart';

class MenuService {
  final String _baseUrl = AppStrings.baseUrl;

  Future<Map<String, dynamic>> getMenu() {
    return ApiClient.get(Uri.parse('$_baseUrl/menu'));
  }

  Future<Map<String, dynamic>> addItem(MenuItemModel item, String token) {
    return ApiClient.post(
      Uri.parse('$_baseUrl/menu'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item.toJson()),
    );
  }

  Future<Map<String, dynamic>> updateItem(MenuItemModel item, String token) {
    return ApiClient.put(
      Uri.parse('$_baseUrl/menu/${item.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(item.toJson()),
    );
  }

  Future<Map<String, dynamic>> deleteItem(int id, String token) {
    return ApiClient.delete(
      Uri.parse('$_baseUrl/menu/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<Map<String, dynamic>> searchMenu(String query) {
    return ApiClient.get(Uri.parse('$_baseUrl/menu/search?query=$query'));
  }
}
