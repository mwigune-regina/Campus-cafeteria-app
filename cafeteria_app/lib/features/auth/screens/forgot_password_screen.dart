import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section (Same as Register/Login)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 30),
              decoration: BoxDecoration(
                color: AppColors.navyBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Back Button
                      Positioned(
                        left: 20,
                        top: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ),
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.restaurant, color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Campus Cafeteria',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Student Portal',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forgot Password?',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your registered Email address and we\'ll send you instructions to reset password',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'username@gmail.com',
                  ),
                  const SizedBox(height: 100), // Spacing to push button down
                  CustomButton(
                    text: 'Send Reset Link',
                    isLoading: _isLoading,
                    onPressed: _handleSendResetLink,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Need help? Contact support at',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Cafeteria-support@university.edu',
                      style: GoogleFonts.poppins(
                        color: AppColors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendResetLink() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final service = AuthService();
    final res = await service.forgotPassword(_emailController.text);
    setState(() => _isLoading = false);

    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to your email')),
        );
        context.push('/verify-code', extra: _emailController.text);
      }
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => ErrorDialog(message: res['message']),
        );
      }
    }
  }
}
