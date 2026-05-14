import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../providers/wallet_provider.dart';

enum _TxFilter { all, payments, topups }

class WalletHomeScreen extends ConsumerStatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  ConsumerState<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends ConsumerState<WalletHomeScreen> {
  _TxFilter _filter = _TxFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).fetchBalance();
      ref.read(walletProvider.notifier).fetchTransactions();
    });
  }

  bool _accept(Map<String, dynamic> tx) {
    final type = tx['type'] ?? 'topup';
    switch (_filter) {
      case _TxFilter.all:
        return true;
      case _TxFilter.payments:
        return type == 'payment';
      case _TxFilter.topups:
        return type == 'topup';
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final filtered = wallet.transactions.where(_accept).toList();

    // group by day
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final tx in filtered) {
      final date = DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now();
      grouped.putIfAbsent(_dayLabel(date), () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 12, 12, 16),
              decoration: BoxDecoration(color: AppColors.navyBlue),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 48), // balance the filter icon
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Transaction History',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Balance card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CURRENT BALANCE',
                                style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 0.6),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                Currency.format(wallet.balance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => context.push('/wallet/topup'),
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _tab('All', _TxFilter.all),
                    _tab('Payments', _TxFilter.payments),
                    _tab('Top-Ups', _TxFilter.topups),
                  ],
                ),
              ),
            ),

            // List
            Expanded(
              child: wallet.isLoading && wallet.transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(walletProvider.notifier).fetchBalance();
                        await ref.read(walletProvider.notifier).fetchTransactions();
                      },
                      child: filtered.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: 80),
                                Center(
                                  child: Text('No transactions yet',
                                      style: TextStyle(color: AppColors.textLight)),
                                ),
                              ],
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              children: grouped.entries.expand((entry) {
                                return [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                                    child: Text(
                                      entry.key.toUpperCase(),
                                      style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                  ...entry.value.map(_row),
                                ];
                              }).toList(),
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, _TxFilter value) {
    final selected = _filter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(Map<String, dynamic> tx) {
    final amt = tx['amount'];
    final amount = amt is String ? double.parse(amt) : (amt as num).toDouble();
    final date = DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now();
    final type = tx['type'] ?? 'topup';
    final isTopup = type == 'topup';
    final reference = (tx['reference'] ?? '').toString();
    final method = (tx['payment_method'] ?? '').toString();

    final title = _titleFor(type, reference);
    final iconBundle = _iconFor(type, reference);

    final statusLabel = isTopup
        ? (method.isNotEmpty ? method : 'Mobile Money')
        : 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBundle.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconBundle.icon, color: iconBundle.foreground, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat('hh:mm a').format(date)}${reference.isNotEmpty ? '  •  ID: #$reference' : ''}',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isTopup ? '+' : '-'}${Currency.format(amount)}',
                style: TextStyle(
                  color: isTopup ? AppColors.success : AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                statusLabel,
                style: TextStyle(color: AppColors.textLight, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _titleFor(String type, String reference) {
    if (type == 'topup') return 'Wallet Top-Up';
    if (type == 'refund') return 'Refund';
    // payment
    return 'Cafeteria Order';
  }

  _IconBundle _iconFor(String type, String reference) {
    if (type == 'topup') {
      return _IconBundle(
        icon: Icons.account_balance_wallet,
        background: AppColors.successBg,
        foreground: AppColors.success,
      );
    }
    if (type == 'refund') {
      return _IconBundle(
        icon: Icons.replay,
        background: AppColors.infoBg,
        foreground: AppColors.navyBlue,
      );
    }
    // payment - vary icon slightly by reference hash for visual variety
    final i = reference.hashCode.abs() % 3;
    if (i == 0) {
      return _IconBundle(
        icon: Icons.restaurant,
        background: AppColors.warningBg,
        foreground: AppColors.orange,
      );
    }
    if (i == 1) {
      return _IconBundle(
        icon: Icons.local_cafe,
        background: AppColors.warningBg,
        foreground: AppColors.orange,
      );
    }
    return _IconBundle(
      icon: Icons.local_drink,
      background: AppColors.infoBg,
      foreground: AppColors.navyBlue,
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
    final base = DateFormat('dd MMM').format(date);
    if (isToday) return 'Today, $base';
    if (isYesterday) return 'Yesterday, $base';
    if (date.year == now.year) return base;
    return DateFormat('dd MMM, yyyy').format(date);
  }
}

class _IconBundle {
  final IconData icon;
  final Color background;
  final Color foreground;
  const _IconBundle({
    required this.icon,
    required this.background,
    required this.foreground,
  });
}
