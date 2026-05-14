import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency.dart';

class OrderQRScreen extends StatelessWidget {
  final String token;
  final dynamic orderId;
  final double? amount;

  const OrderQRScreen({
    super.key,
    required this.token,
    this.orderId,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(orderId != null ? 'Order #$orderId' : 'Your QR'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Show this QR code to the cashier',
                  style: TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: token,
                    version: QrVersions.auto,
                    size: 220,
                    eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.navyBlue),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.navyBlue,
                    ),
                  ),
                ),
              ),
              if (amount != null) ...[
                const SizedBox(height: 28),
                Center(
                  child: Text(
                    '${Currency.format(amount!)} paid',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successDark,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/orders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navyBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
