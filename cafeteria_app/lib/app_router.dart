import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'features/auth/screens/landing_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/menu/screens/student_menu_screen.dart';
import 'features/menu/screens/add_item_screen.dart';
import 'features/cart/screens/cart_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: context.read<AuthProvider>(),
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final loggingIn = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register' || 
                           state.matchedLocation == '/' ||
                           state.matchedLocation == '/forgot-password';

        if (!authProvider.isAuthenticated) {
          return loggingIn ? null : '/';
        }

        if (loggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/menu', builder: (context, state) => const StudentMenuScreen()),
        GoRoute(path: '/add-item', builder: (context, state) => const AddItemScreen()),
        GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      ],
    );
  }
}
