import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: AppColors.navyBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            AuthTextField(controller: _usernameController, label: 'Username'),
            const SizedBox(height: 18),
            AuthTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 18),
            AuthTextField(controller: _passwordController, label: 'Password', obscureText: true),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (val) => setState(() => _role = val!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Register',
              onPressed: () async {
                final service = AuthService();
                final res = await service.register(
                  _usernameController.text,
                  _emailController.text,
                  _passwordController.text,
                  _role,
                );
                if (res['success']) {
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
