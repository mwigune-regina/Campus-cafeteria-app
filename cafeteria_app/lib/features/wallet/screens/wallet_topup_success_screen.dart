import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';

class WalletTopupSuccessScreen extends StatelessWidget {
  final double amount;
  final double newBalance;
  final String? transactionId;
  final String? paymentMethod;
  final String? createdAt;

  const WalletTopupSuccessScreen({
    super.key,
    required this.amount,
    required this.newBalance,
    this.transactionId,
    this.paymentMethod,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final date = createdAt != null ? DateTime.tryParse(createdAt!) : DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Confirmation',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => context.go('/wallet'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 18),

            // Green check circle (outer ring + filled inner)
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.successBg,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Top-Up Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              Currency.format(amount),
              style: TextStyle(
                fontSize: 28,
                color: AppColors.successDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New Balance: ${Currency.format(newBalance)}',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),

            const SizedBox(height: 22),

            // Transaction details card — white with shadow
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSACTION DETAILS',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _row('Transaction ID', '#${transactionId ?? '—'}'),
                  const SizedBox(height: 12),
                  _row('Payment Method', paymentMethod ?? 'M-Pesa'),
                  const SizedBox(height: 12),
                  _row(
                    'Date & Time',
                    date != null ? DateFormat('MMM dd, yyyy · HH:mm').format(date) : '—',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Decorative three-dots + line
            const _DotsDecoration(),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Back to Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text(
                'View Receipt',
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/wallet'),
              child: Text(
                'View Transaction History',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textLight, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DotsDecoration extends StatelessWidget {
  const _DotsDecoration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft blobs on the sides (subtle)
          Positioned(
            left: 0,
            child: Container(
              width: 90,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 90,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          // Center three dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(AppColors.orange),
              const SizedBox(width: 6),
              _dot(AppColors.navyBlue),
              const SizedBox(width: 6),
              _dot(AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
