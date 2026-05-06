import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.restaurant, color: AppColors.navyBlue, size: 80),
              const SizedBox(height: 12),
              const Text(
                'Campus Cafeteria',
                style: TextStyle(
                  color: AppColors.navyBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(flex: 2),
              const Text(
                'Fast, Easy, Cashless.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(flex: 3),
              CustomButton(
                text: 'Get Started',
                onPressed: () => context.go('/register'),
                backgroundColor: AppColors.orange,
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Login',
                onPressed: () => context.go('/login'),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
