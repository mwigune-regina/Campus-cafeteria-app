import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/order_provider.dart';

class CashierDashboardScreen extends ConsumerStatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  ConsumerState<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends ConsumerState<CashierDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cashierQueueProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierQueueProvider);
    final activeCount = state.orders.length;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: AppColors.navyBlue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Food Server Dashboard',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/');
                    },
                  ),
                ],
              ),
            ),
            // Subheader
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.list_alt, size: 18, color: AppColors.textDark),
                  const SizedBox(width: 8),
                  const Text('Order Queue',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$activeCount Active',
                      style: TextStyle(
                        color: AppColors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ref.read(cashierQueueProvider.notifier).fetch(),
                    child: Text('Clear Completed',
                        style: TextStyle(color: AppColors.textLight)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading && state.orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => ref.read(cashierQueueProvider.notifier).fetch(),
                      child: state.orders.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 80),
                                Center(child: Text('No active orders', style: TextStyle(color: AppColors.textLight))),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: state.orders.length,
                              itemBuilder: (ctx, i) => _OrderCard(order: state.orders[i]),
                            ),
                    ),
            ),
            // Scan QR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/cashier/scan'),
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text('Scan QR Code',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = order['id'];
    final username = order['username'] ?? 'Student';
    final status = (order['status'] as String?) ?? 'paid';
    final items = (order['items'] as List?) ?? [];
    final created = DateTime.parse(order['created_at']);

    final summary = items
        .take(3)
        .map((it) => '${it['item_name'] ?? 'Item'} ×${it['quantity']}')
        .join(', ');

    final isReady = status == 'ready';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isReady ? AppColors.success : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Order #$id',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(width: 8),
                        if (isReady)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('READY',
                                style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Text('Student: $username',
                        style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(DateFormat('HH:mm').format(created),
                      style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restaurant, color: AppColors.textLight),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.isEmpty ? 'No items' : 'Items: $summary',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(Currency.format(double.parse(order['total_amount'].toString())),
                        style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statusBtn(
                  context,
                  ref,
                  label: 'Preparing',
                  color: AppColors.orange,
                  active: status == 'preparing',
                  onTap: () => ref.read(cashierQueueProvider.notifier).updateStatus(id, 'preparing'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusBtn(
                  context,
                  ref,
                  label: 'Ready',
                  color: AppColors.navyBlue,
                  active: status == 'ready',
                  onTap: () => ref.read(cashierQueueProvider.notifier).updateStatus(id, 'ready'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusBtn(
                  context,
                  ref,
                  label: 'Cancel',
                  color: AppColors.danger,
                  active: false,
                  onTap: () => ref.read(cashierQueueProvider.notifier).updateStatus(id, 'cancelled'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBtn(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required Color color,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
