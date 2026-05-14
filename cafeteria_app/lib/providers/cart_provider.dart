import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

class CartState {
  final Map<int, CartItemModel> items;

  CartState({this.items = const {}});

  List<CartItemModel> get itemList => items.values.toList();
  
  double get totalAmount {
    double total = 0.0;
    items.forEach((key, value) {
      total += value.totalPrice;
    });
    return total;
  }

  CartState copyWith({Map<int, CartItemModel>? items}) {
    return CartState(
      items: items ?? this.items,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addToCart(MenuItemModel item) {
    final newItems = Map<int, CartItemModel>.from(state.items);
    if (newItems.containsKey(item.id)) {
      final existingItem = newItems[item.id]!;
      newItems[item.id] = CartItemModel(
        menuItem: existingItem.menuItem,
        quantity: existingItem.quantity + 1,
      );
    } else {
      newItems[item.id] = CartItemModel(menuItem: item);
    }
    state = state.copyWith(items: newItems);
  }

  void removeFromCart(int id) {
    final newItems = Map<int, CartItemModel>.from(state.items);
    newItems.remove(id);
    state = state.copyWith(items: newItems);
  }

  void increment(int id) {
    final newItems = Map<int, CartItemModel>.from(state.items);
    final existing = newItems[id];
    if (existing == null) return;
    newItems[id] = CartItemModel(menuItem: existing.menuItem, quantity: existing.quantity + 1);
    state = state.copyWith(items: newItems);
  }

  void decrement(int id) {
    final newItems = Map<int, CartItemModel>.from(state.items);
    final existing = newItems[id];
    if (existing == null) return;
    if (existing.quantity <= 1) {
      newItems.remove(id);
    } else {
      newItems[id] = CartItemModel(menuItem: existing.menuItem, quantity: existing.quantity - 1);
    }
    state = state.copyWith(items: newItems);
  }

  void clearCart() {
    state = CartState();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
