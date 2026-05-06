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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AuthTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Reset Password',
              onPressed: () async {
                final service = AuthService();
                final res = await service.forgotPassword(_emailController.text);
                if (res['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent to email')));
                  context.go('/login');
                } else {
                  showDialog(context: context, builder: (ctx) => ErrorDialog(message: res['message']));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
