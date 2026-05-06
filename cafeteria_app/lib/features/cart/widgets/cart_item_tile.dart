import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(item.menuItem.name[0])),
      title: Text(item.menuItem.name),
      subtitle: Text('\${item.quantity} x \$${item.menuItem.price.toStringAsFixed(2)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => Provider.of<CartProvider>(context, listen: false).removeFromCart(item.menuItem.id),
          ),
        ],
      ),
    );
  }
}
