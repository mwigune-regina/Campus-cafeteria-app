import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/order_provider.dart';

class CashierHistoryScreen extends ConsumerStatefulWidget {
  const CashierHistoryScreen({super.key});

  @override
  ConsumerState<CashierHistoryScreen> createState() => _CashierHistoryScreenState();
}

class _CashierHistoryScreenState extends ConsumerState<CashierHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(_load);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _load() {
    String? status;
    if (_tab.index == 1) status = 'served';
    if (_tab.index == 2) status = 'paid';
    ref.read(cashierHistoryProvider.notifier).fetch(statusFilter: status);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashierHistoryProvider);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final o in state.orders) {
      final date = DateTime.parse(o['created_at']);
      final dayKey = _dayLabel(date);
      grouped.putIfAbsent(dayKey, () => []).add(o);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Order History',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.search, color: AppColors.textDark), onPressed: () {}),
          IconButton(icon: Icon(Icons.tune, color: AppColors.textDark), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.navyBlue,
          labelColor: AppColors.navyBlue,
          unselectedLabelColor: AppColors.textLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All Orders'),
            Tab(text: 'Served'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: state.isLoading && state.orders.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView(
                children: grouped.entries.expand((entry) {
                  return [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: AppColors.lightGray,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              )),
                          Text('${entry.value.length} Orders Total',
                              style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                        ],
                      ),
                    ),
                    ...entry.value.map(_tile),
                  ];
                }).toList(),
              ),
            ),
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
    final base = DateFormat('MMM dd').format(date).toUpperCase();
    if (isToday) return 'Today, $base';
    if (isYesterday) return 'Yesterday, $base';
    return base;
  }

  Widget _tile(Map<String, dynamic> o) {
    final date = DateTime.parse(o['created_at']);
    final status = (o['status'] ?? '').toString();
    final isServed = status == 'served';
    final relative = _relative(date);

    return InkWell(
      onTap: () => context.push('/cashier/order-detail', extra: o),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isServed ? AppColors.successBg : AppColors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                isServed ? Icons.check : Icons.access_time,
                color: isServed ? AppColors.success : AppColors.orange,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${o['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    isServed ? 'Served · $relative' : '${status.toUpperCase()} · $relative',
                    style: TextStyle(
                      color: isServed ? AppColors.success : AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(DateFormat('HH:mm').format(date),
                style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  String _relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return DateFormat('MMM dd').format(date);
  }
}
