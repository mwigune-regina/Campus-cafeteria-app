import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Cafeteria'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, \${user?.username ?? "User"}!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Role: \${user?.role}', style: const TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 40),
            _buildActionCard(
              context,
              title: 'Browse Menu',
              icon: Icons.restaurant_menu,
              onTap: () => context.push('/menu'),
            ),
            const SizedBox(height: 20),
            if (user?.role == 'student')
              _buildActionCard(
                context,
                title: 'My Cart',
                icon: Icons.shopping_cart,
                onTap: () => context.push('/cart'),
              ),
            if (user?.role == 'admin')
              _buildActionCard(
                context,
                title: 'Add New Item',
                icon: Icons.add_circle,
                onTap: () => context.push('/add-item'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.navyBlue, size: 32),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
