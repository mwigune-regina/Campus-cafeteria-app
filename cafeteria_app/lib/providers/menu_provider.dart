import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _menuService = MenuService();
  List<MenuItemModel> _items = [];
  bool _isLoading = false;

  List<MenuItemModel> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchMenu() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _menuService.getMenu();
      if (response['success']) {
        _items = (response['data'] as List)
            .map((item) => MenuItemModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> addMenuItem(MenuItemModel item, String token) async {
    try {
      final response = await _menuService.addItem(item, token);
      if (response['success']) {
        await fetchMenu();
        return null;
      }
      return response['message'];
    } catch (e) {
      return e.toString();
    }
  }
}
