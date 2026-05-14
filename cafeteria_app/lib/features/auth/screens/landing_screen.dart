import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Header Icon and Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.navyBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.restaurant, color: AppColors.navyBlue, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Campus Cafeteria',
                        style: GoogleFonts.poppins(
                          color: AppColors.navyBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Main Image with custom rounded corners
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1567521464027-f127ff144326?q=80&w=1000&auto=format&fit=crop',
                      height: 320,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                    children: [
                      TextSpan(text: 'Fast, Easy,\n', style: TextStyle(color: AppColors.navyBlue)),
                      TextSpan(text: 'Cashless.', style: TextStyle(color: AppColors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  'Enjoy your meals without the wait\nusing your digital university wallet.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.textLight,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Buttons
                CustomButton(
                  text: 'Get Started',
                  onPressed: () => context.push('/register'),
                  backgroundColor: AppColors.orange,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Login',
                  onPressed: () => context.push('/login'),
                  backgroundColor: AppColors.navyBlue,
                ),
                const SizedBox(height: 30),
                // Footer
                Text(
                  '@2026 University Cafeteria System',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
