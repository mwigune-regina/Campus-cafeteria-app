import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../providers/order_provider.dart';

class CashierOrderDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> order;

  const CashierOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = order['id'];
    final username = order['username'] ?? 'Student';
    final status = (order['status'] ?? '').toString();
    final items = (order['items'] as List?) ?? [];
    final total = double.parse(order['total_amount'].toString());
    final created = DateTime.parse(order['created_at']);

    final isServed = status == 'served';

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: Text(
          'Order #$id',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert, color: AppColors.textDark),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CUSTOMER INFORMATION',
                style: TextStyle(color: AppColors.textLight, fontSize: 12, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person_outline, color: AppColors.navyBlue, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student ID: $username',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, size: 14, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text('Paid via Wallet',
                                style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('ITEMIZED LIST',
                style: TextStyle(color: AppColors.textLight, fontSize: 12, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: List.generate(items.length, (i) {
                  final it = items[i];
                  final qty = it['quantity'] as num;
                  final price = double.parse(it['price_at_time'].toString());
                  final last = i == items.length - 1;
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: last ? BorderSide.none : BorderSide(color: Colors.grey.shade100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.restaurant, color: AppColors.navyBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(it['item_name'] ?? 'Item',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (it['category'] != null)
                                Text(it['category'].toString(),
                                    style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('×$qty', style: TextStyle(color: AppColors.textLight)),
                        const SizedBox(width: 12),
                        Text(Currency.amountOnly(price * qty),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            _row('Subtotal', Currency.format(total)),
            _row('Service Fee', '${Currency.symbol()} 0'),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Cost',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(Currency.format(total),
                    style: TextStyle(
                        color: AppColors.navyBlue, fontWeight: FontWeight.bold, fontSize: 22)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ordered at ${DateFormat('hh:mm a').format(created)}. Payment confirmed via student e-wallet balance.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isServed
                    ? null
                    : () async {
                        final ok = await ref
                            .read(cashierQueueProvider.notifier)
                            .updateStatus(id, 'served');
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Text('Order #$id successfully served',
                                      style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              backgroundColor: Colors.white,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          context.pop();
                        }
                      },
                icon: Icon(
                  isServed ? Icons.check : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  isServed ? 'SERVED' : 'SERVE ORDER',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textLight, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
