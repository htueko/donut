import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_flow_provider.dart';
import '../features/auth/presentation/screens/dob_screen.dart';
import '../features/auth/presentation/screens/name_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/phone_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/product/presentation/product_detail_screen.dart';
import '../features/rewards/presentation/rewards_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'shell/app_shell.dart';

class _SessionRefresh extends ChangeNotifier {
  _SessionRefresh(this._ref) {
    _ref.listen<int>(
      sessionControllerProvider.select((user) => user?.id.hashCode ?? 0),
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
}

final routerProvider = Provider<GoRouter>((ref) {
  final sessionRefresh = _SessionRefresh(ref);
  ref.onDispose(sessionRefresh.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: sessionRefresh,
    redirect: (context, state) {
      final user = ref.read(sessionControllerProvider);
      final loggedIn = user != null;
      final location = state.matchedLocation;
      final inAuthFlow =
          location.startsWith('/onboarding') ||
          location.startsWith('/login') ||
          location.startsWith('/register');
      if (!loggedIn && !inAuthFlow) {
        return '/onboarding';
      }
      if (loggedIn && inAuthFlow) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login/phone',
        builder: (context, state) => const PhoneScreen(isLogin: true),
      ),
      GoRoute(
        path: '/login/otp',
        builder: (context, state) => const OtpScreen(isLogin: true),
      ),
      GoRoute(
        path: '/register/phone',
        builder: (context, state) => const PhoneScreen(isLogin: false),
      ),
      GoRoute(
        path: '/register/otp',
        builder: (context, state) => const OtpScreen(isLogin: false),
      ),
      GoRoute(
        path: '/register/name',
        builder: (context, state) => const NameScreen(),
      ),
      GoRoute(
        path: '/register/dob',
        builder: (context, state) => const DobScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
    ],
  );
});
