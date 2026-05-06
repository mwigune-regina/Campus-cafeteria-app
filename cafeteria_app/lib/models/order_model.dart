import 'cart_item_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String status; // 'pending', 'preparing', 'ready', 'completed'
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
