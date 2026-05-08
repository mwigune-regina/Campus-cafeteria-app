import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your email address and we will send you a link to reset your password.',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            AuthTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Send Reset Link',
              isLoading: _isLoading,
              onPressed: () async {
                if (_emailController.text.isEmpty) return;
                
                setState(() => _isLoading = true);
                final service = AuthService();
                final res = await service.forgotPassword(_emailController.text);
                setState(() => _isLoading = false);

                if (res['success']) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reset link sent to your email')),
                    );
                    context.pop();
                  }
                } else {
                  if (context.mounted) {
                    showDialog(
                      context: context, 
                      builder: (ctx) => ErrorDialog(message: res['message']),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
