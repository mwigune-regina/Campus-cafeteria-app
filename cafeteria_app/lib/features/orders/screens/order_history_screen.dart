import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/order_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/loading_spinner.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myOrdersProvider.notifier).fetch();
    });
  }

  bool _isUnchecked(Map<String, dynamic> o) {
    final s = o['status'] as String;
    return s == 'paid' || s == 'preparing' || s == 'ready';
  }

  bool _isChecked(Map<String, dynamic> o) => o['status'] == 'served';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myOrdersProvider);

    final unchecked = state.orders.where(_isUnchecked).toList();
    final checked = state.orders.where(_isChecked).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: AppColors.navyBlue),
              child: const Center(
                child: Text(
                  'Orders',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const LoadingSpinner()
                  : RefreshIndicator(
                      onRefresh: () => ref.read(myOrdersProvider.notifier).fetch(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        children: [
                          _section('UNCHECKED ORDERS'),
                          if (unchecked.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('No pending orders', style: TextStyle(color: AppColors.textLight)),
                            )
                          else
                            ...unchecked.map((o) => _uncheckedTile(o)),
                          const SizedBox(height: 24),
                          _section('CHECKED ORDERS'),
                          if (checked.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('No served orders yet', style: TextStyle(color: AppColors.textLight)),
                            )
                          else
                            ...checked.map((o) => _checkedTile(o)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(color: AppColors.textLight, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }

  Widget _uncheckedTile(Map<String, dynamic> o) {
    final date = DateTime.parse(o['created_at']);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          '/order-qr',
          extra: {
            'token': o['qr_code_token'],
            'orderId': o['id'],
            'amount': double.tryParse(o['total_amount'].toString()),
          },
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${o['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('view Qr code',
                        style: TextStyle(color: AppColors.orange, fontSize: 13)),
                  ],
                ),
              ),
              Text(
                DateFormat('HH:mm').format(date),
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkedTile(Map<String, dynamic> o) {
    final date = DateTime.parse(o['created_at']);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/order-details', extra: o),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${o['id']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      'Served · ${DateFormat('MMM dd').format(date)}',
                      style: TextStyle(color: AppColors.textLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('HH:mm').format(date),
                style: TextStyle(color: AppColors.textLight, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
