import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';

class CartItemTile extends ConsumerWidget {
  final CartItemModel item;
  final VoidCallback onDelete;

  const CartItemTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.menuItem.imageUrl != null && item.menuItem.imageUrl!.isNotEmpty
                ? Image.network(
                    item.menuItem.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.menuItem.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Currency.format(item.menuItem.price)}.00',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.orange),
            onPressed: onDelete,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          _RoundIcon(
            icon: Icons.remove,
            onTap: () => ref.read(cartProvider.notifier).decrement(item.menuItem.id),
          ),
          const SizedBox(width: 6),
          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          _RoundIcon(
            icon: Icons.add,
            onTap: () => ref.read(cartProvider.notifier).increment(item.menuItem.id),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      color: Colors.white,
      child: Icon(Icons.fastfood, color: AppColors.textLight),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.orange, width: 1.4),
        ),
        child: Icon(icon, color: AppColors.orange, size: 16),
      ),
    );
  }
}
