import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
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
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBlue,
                    ),
                  ),
                  Text(
                    'Join the campus cafeteria system',
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
                  const SizedBox(height: 18),
                  AuthTextField(
                    controller: _regNumberController,
                    label: 'Registration Number',
                    hintText: '20**-00-*****',
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 18),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Enter password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  // Terms and conditions checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (val) => setState(() => _agreedToTerms = val!),
                        activeColor: AppColors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(color: AppColors.navyBlue, fontSize: 13),
                            children: [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(text: 'terms', style: TextStyle(color: AppColors.orange)),
                              TextSpan(text: ' and '),
                              TextSpan(text: 'privacy policy', style: TextStyle(color: AppColors.orange)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Create Account',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Already have an account',
                      style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Sign In button with orange border
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.poppins(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      '@2026 University Cafeteria System',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontSize: 12,
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

  void _handleRegister() async {
    if (!_agreedToTerms) {
      _showError('Please agree to the terms and privacy policy');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    if (_emailController.text.isEmpty || _regNumberController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);
    final service = AuthService();
    final res = await service.register(
      _regNumberController.text, // Using reg number as username
      _emailController.text,
      _passwordController.text,
      'student',
    );
    setState(() => _isLoading = false);

    if (res['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        context.pop();
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
