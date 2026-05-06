import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/menu_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final bool isAdmin;

  const MenuItemCard({super.key, required this.item, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: AppColors.lightGray, child: const Icon(Icons.fastfood, size: 50)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (!isAdmin)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addToCart(item);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\${item.name} added to cart')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.navyBlue),
                      child: const Text('Add to Cart'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
