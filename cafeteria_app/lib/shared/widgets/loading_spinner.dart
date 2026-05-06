import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.navyBlue),
    );
  }
}
