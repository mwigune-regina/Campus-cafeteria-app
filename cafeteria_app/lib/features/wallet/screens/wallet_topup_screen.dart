import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';
import '../../../providers/wallet_provider.dart';

class WalletTopupScreen extends ConsumerStatefulWidget {
  const WalletTopupScreen({super.key});

  @override
  ConsumerState<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends ConsumerState<WalletTopupScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedMethod = 'M-Pesa';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).fetchBalance();
      ref.read(walletProvider.notifier).fetchTransactions();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(int amount) {
    setState(() => _amountController.text = amount.toString());
  }

  Future<void> _submit() async {
    final raw = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ref.read(walletProvider.notifier).topUp(amount, _selectedMethod);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res == null) {
      context.push('/wallet/topup-failed', extra: {'amount': amount});
      return;
    }

    final newBalance = res['new_balance'];
    context.push('/wallet/topup-success', extra: {
      'amount': amount,
      'newBalance': newBalance is String ? double.parse(newBalance) : (newBalance as num).toDouble(),
      'transactionId': res['transaction_id'],
      'paymentMethod': res['payment_method'],
      'createdAt': res['created_at'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Top-Up Wallet',
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
          icon: Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.navyBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Current Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Text('Enter Amount',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 16, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: "Tsh 0'00",
                hintStyle: TextStyle(color: AppColors.textLight),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.navyBlue, size: 20),
                ),
                filled: true,
                fillColor: AppColors.lightGray,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: AppColors.orange, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                _quickAmount(2000),
                const SizedBox(width: 10),
                _quickAmount(5000),
                const SizedBox(width: 10),
                _quickAmount(10000),
              ],
            ),

            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Method',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Add New',
                    style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            _paymentTile('M-Pesa', 'Vodacom Tanzania', AppColors.vodacomRed),
            const SizedBox(height: 8),
            _paymentTile('TigoPesa', 'Tigo Tanzania', AppColors.tigoBlue),

            const SizedBox(height: 22),
            const Text('Recent Transactions',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            ...wallet.transactions.take(3).map((tx) {
              final amt = tx['amount'];
              final amount = amt is String ? double.parse(amt) : (amt as num).toDouble();
              final date = DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now();
              final type = tx['type'] ?? 'topup';
              final isTopup = type == 'topup';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.check, color: AppColors.successDark, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTopup
                                ? 'Top-up via ${tx['payment_method'] ?? ''}'
                                : 'Payment',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(date),
                            style: TextStyle(color: AppColors.textLight, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isTopup ? '+' : '-'}${Currency.format(amount)}',
                      style: TextStyle(
                        color: isTopup ? AppColors.successDark : AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Confirm Top-Up',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'By clicking confirm, you agree to our terms of service\nand applicable provider transaction fees.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAmount(int amount) {
    final selected = _amountController.text == amount.toString();
    return GestureDetector(
      onTap: () => _setAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.navyBlue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(30),
          color: selected ? AppColors.navyBlue.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Text(
          '+${NumberFormat('#,###').format(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? AppColors.navyBlue : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(String name, String subtitle, Color accent) {
    final selected = _selectedMethod == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.orange : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Custom radio (filled dot when selected, hollow ring when not)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.orange : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.smartphone, color: accent, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
