import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(order['created_at']);
    final status = (order['status'] ?? '').toString();
    final items = (order['items'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order #${order['id']}'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Status', status.toUpperCase(), color: _statusColor(status)),
            _row('Date', DateFormat('MMM dd, yyyy · HH:mm').format(date)),
            _row(
              'Total',
              Currency.format(double.parse(order['total_amount'].toString())),
              color: AppColors.orange,
            ),
            const Divider(height: 40),
            const Text('Items',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...items.map((it) {
              final name = it['item_name'] ?? 'Item #${it['menu_item_id']}';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('$name × ${it['quantity']}'),
                    ),
                    Text(
                      Currency.format(double.parse(it['price_at_time'].toString()) * (it['quantity'] as num)),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'served':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      case 'paid':
      case 'preparing':
      case 'ready':
        return AppColors.orange;
      default:
        return AppColors.textLight;
    }
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textLight, fontSize: 15)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}
