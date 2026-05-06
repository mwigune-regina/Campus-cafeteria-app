import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _usernameController,
                        label: 'Username',
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Sign In',
                        isLoading: authProvider.isLoading,
                        onPressed: () async {
                          final error = await authProvider.login(
                            _usernameController.text,
                            _passwordController.text,
                          );
                          if (error != null) {
                            showDialog(
                              context: context,
                              builder: (ctx) => ErrorDialog(message: error),
                            );
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text("Don't have an account? Register"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.navyBlue,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Column(
        children: [
          Icon(Icons.restaurant, color: Colors.white, size: 60),
          Text(
            'Campus Cafeteria',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
