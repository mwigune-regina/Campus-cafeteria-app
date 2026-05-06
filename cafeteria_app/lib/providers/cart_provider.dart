import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItemModel> _items = {};

  List<CartItemModel> get items => _items.values.toList();
  
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, value) {
      total += value.totalPrice;
    });
    return total;
  }

  void addToCart(MenuItemModel item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity++;
    } else {
      _items[item.id] = CartItemModel(menuItem: item);
    }
    notifyListeners();
  }

  void removeFromCart(int id) {
    _items.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
