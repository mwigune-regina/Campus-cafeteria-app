import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/order_service.dart';
import '../widgets/cart_item_tile.dart';
import '../../../shared/widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItemTile(item: cart.items[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('\$${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Place Order',
                  onPressed: cart.items.isEmpty ? () {} : () async {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final service = OrderService();
                    final res = await service.placeOrder(cart.items, cart.totalAmount, auth.token!);
                    if (res['success']) {
                      cart.clearCart();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
