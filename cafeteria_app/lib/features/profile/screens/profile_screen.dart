import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/theme_picker_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final palette = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: AppColors.navyBlue),
              child: Center(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              // Fill the row width so this card matches the menu card below it
              // (which is full-width because its rows are). Without this the card
              // would shrink to its widest child (avatar/name/pill).
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              // Even vertical breathing room top/bottom; the inner gaps below
              // follow a ~1.6 rhythm (avatar->name : name->role) so the cluster
              // reads as balanced now that the email line is gone.
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ProfileAvatar(),
                  if (user != null) ...[
                    const SizedBox(height: 20),
                    Text(user.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Personal-info screen lives in the student shell; only route
                  // students there so cashiers don't land in the wrong shell.
                  _row(Icons.info_outline, 'Personal information',
                      onTap: user?.role == 'student'
                          ? () => context.push('/profile/personal-info')
                          : null),
                  _row(Icons.lock_outline, 'Privacy', onTap: () {}),
                  _row(Icons.notifications_outlined, 'Notifications', onTap: () {}),
                  _row(
                    Icons.palette_outlined,
                    'App Theme',
                    trailing: _ThemeTrailing(paletteName: palette.name),
                    onTap: () => ThemePickerSheet.show(context),
                  ),
                  _row(Icons.settings_outlined, 'Settings', onTap: () {}),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/');
                  },
                  icon: Icon(Icons.logout, color: AppColors.danger),
                  label: Text(
                    'Log Out',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textDark),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
            ),
            if (trailing != null) ...[
              trailing,
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _ThemeTrailing extends StatelessWidget {
  final String paletteName;
  const _ThemeTrailing({required this.paletteName});

  @override
  Widget build(BuildContext context) {
    return Text(
      paletteName,
      style: TextStyle(
        color: AppColors.textLight,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
