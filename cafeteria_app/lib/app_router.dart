import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

// Auth
import 'features/auth/screens/landing_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/verify_code_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';

// Student
import 'features/menu/screens/student_menu_screen.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/orders/screens/order_details_screen.dart';
import 'features/orders/screens/order_qr_screen.dart';
import 'features/wallet/screens/wallet_home_screen.dart';
import 'features/wallet/screens/wallet_topup_screen.dart';
import 'features/wallet/screens/wallet_topup_success_screen.dart';
import 'features/wallet/screens/wallet_topup_failed_screen.dart';
import 'features/profile/screens/profile_screen.dart';

// Cashier
import 'features/cashier/screens/cashier_dashboard_screen.dart';
import 'features/cashier/screens/cashier_order_detail_screen.dart';
import 'features/cashier/screens/cashier_history_screen.dart';
import 'features/orders/screens/qr_scanner_screen.dart';

// Shared
import 'shared/widgets/student_scaffold.dart';

/// Bridges Riverpod's [authProvider] state changes to a [Listenable] that
/// [GoRouter] can listen to via `refreshListenable`. This way the router stays
/// the same instance across the app's lifetime — we just ask it to
/// re-evaluate its redirect when auth state changes.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    _sub = ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
      fireImmediately: false,
    );
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      // Read latest auth on every redirect evaluation so we never see stale
      // captured state.
      final authState = ref.read(authProvider);
      final loc = state.matchedLocation;
      final authRoutes = {
        '/',
        '/login',
        '/register',
        '/forgot-password',
        '/verify-code',
        '/reset-password',
      };
      final isAuthRoute = authRoutes.contains(loc);

      if (!authState.isAuthenticated) {
        return isAuthRoute ? null : '/';
      }

      // Route role-restricted areas
      if (authState.isCashier) {
        // Cashier must not be in student-only areas
        if (isAuthRoute) return '/cashier/queue';
        if (loc.startsWith('/wallet') ||
            loc.startsWith('/cart') ||
            loc == '/orders' ||
            loc == '/order-details' ||
            loc == '/order-qr' ||
            loc == '/home' ||
            loc == '/profile' ||
            loc == '/menu') {
          return '/cashier/queue';
        }
      } else {
        // Student / admin
        if (isAuthRoute) return '/home';
        if (loc.startsWith('/cashier')) return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const LandingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/verify-code',
        builder: (c, s) => VerifyCodeScreen(email: s.extra as String),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (c, s) {
          final data = s.extra as Map<String, dynamic>;
          return ResetPasswordScreen(email: data['email'], code: data['code']);
        },
      ),

      // Student shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) => StudentScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const StudentMenuScreen()),
          GoRoute(path: '/menu', builder: (c, s) => const StudentMenuScreen()),
          GoRoute(path: '/wallet', builder: (c, s) => const WalletHomeScreen()),
          GoRoute(path: '/orders', builder: (c, s) => const OrderHistoryScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),

      // Student detail / flow screens (full-screen, no bottom nav)
      GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
      GoRoute(
        path: '/order-details',
        builder: (c, s) => OrderDetailsScreen(order: s.extra as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/order-qr',
        builder: (c, s) {
          final data = s.extra as Map<String, dynamic>;
          return OrderQRScreen(
            token: data['token'] as String,
            orderId: data['orderId'],
            amount: (data['amount'] as num?)?.toDouble(),
          );
        },
      ),
      GoRoute(path: '/wallet/topup', builder: (c, s) => const WalletTopupScreen()),
      GoRoute(
        path: '/wallet/topup-success',
        builder: (c, s) {
          final d = s.extra as Map<String, dynamic>;
          return WalletTopupSuccessScreen(
            amount: (d['amount'] as num).toDouble(),
            newBalance: (d['newBalance'] as num).toDouble(),
            transactionId: d['transactionId'] as String?,
            paymentMethod: d['paymentMethod'] as String?,
            createdAt: d['createdAt'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/wallet/topup-failed',
        builder: (c, s) {
          final d = s.extra as Map<String, dynamic>;
          return WalletTopupFailedScreen(
            amount: (d['amount'] as num).toDouble(),
            errorCode: d['errorCode'] as String?,
          );
        },
      ),

      // Cashier shell
      ShellRoute(
        builder: (context, state, child) => CashierScaffold(child: child),
        routes: [
          GoRoute(path: '/cashier/queue', builder: (c, s) => const CashierDashboardScreen()),
          GoRoute(path: '/cashier/history', builder: (c, s) => const CashierHistoryScreen()),
          GoRoute(path: '/cashier/profile', builder: (c, s) => const ProfileScreen()),
          GoRoute(
            path: '/cashier/settings',
            builder: (c, s) => const ProfileScreen(),
          ),
        ],
      ),

      // Cashier detail screens (full-screen)
      GoRoute(path: '/cashier/scan', builder: (c, s) => const QRScannerScreen()),
      GoRoute(
        path: '/cashier/order-detail',
        builder: (c, s) => CashierOrderDetailScreen(order: s.extra as Map<String, dynamic>),
      ),
    ],
  );
});
