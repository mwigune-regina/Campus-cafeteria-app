import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
  });

  double get totalPrice => menuItem.price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      menuItem: MenuItemModel.fromJson(json['menu_item']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
    };
  }
}
