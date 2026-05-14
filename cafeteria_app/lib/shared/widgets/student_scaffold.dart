import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class StudentScaffold extends StatelessWidget {
  final Widget child;

  const StudentScaffold({super.key, required this.child});

  static const _tabs = [
    _Tab(route: '/home', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _Tab(route: '/wallet', icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Wallet'),
    _Tab(route: '/orders', icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Orders'),
    _Tab(route: '/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  int _indexFromLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final current = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == current;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(tab.route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? tab.activeIcon : tab.icon,
                          color: selected ? AppColors.navyBlue : AppColors.textLight,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? AppColors.navyBlue : AppColors.textLight,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class CashierScaffold extends StatelessWidget {
  final Widget child;

  const CashierScaffold({super.key, required this.child});

  static const _tabs = [
    _Tab(route: '/cashier/queue', icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt, label: 'Queue'),
    _Tab(route: '/cashier/history', icon: Icons.history_outlined, activeIcon: Icons.history, label: 'History'),
    _Tab(route: '/cashier/profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
    _Tab(route: '/cashier/settings', icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
  ];

  int _indexFromLocation(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final current = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == current;
              return Expanded(
                child: InkWell(
                  onTap: () => context.go(tab.route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selected ? tab.activeIcon : tab.icon,
                          color: selected ? AppColors.navyBlue : AppColors.textLight,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? AppColors.navyBlue : AppColors.textLight,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _Tab({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

