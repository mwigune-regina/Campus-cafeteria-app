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
        backgroundColor: AppColors.navyBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              context.go('/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.username ?? "User"}!',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navyBlue),
            ),
            const SizedBox(height: 4),
            Text(
              'Role: ${user?.role?.toUpperCase()}',
              style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            _buildActionCard(
              context,
              title: 'Browse Menu',
              subtitle: 'Explore today\'s delicious offerings',
              icon: Icons.restaurant_menu,
              onTap: () => context.push('/menu'),
            ),
            const SizedBox(height: 20),
            if (user?.role == 'student')
              _buildActionCard(
                context,
                title: 'My Cart',
                subtitle: 'View items and checkout',
                icon: Icons.shopping_cart,
                onTap: () => context.push('/cart'),
              ),
            if (user?.role == 'admin')
              _buildActionCard(
                context,
                title: 'Manage Menu',
                subtitle: 'Add or edit cafeteria items',
                icon: Icons.edit_note,
                onTap: () => context.push('/add-item'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.navyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.navyBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
