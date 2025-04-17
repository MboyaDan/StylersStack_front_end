import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:stylerstack/views/auth/login_screen.dart';
import 'package:stylerstack/views/auth/registration_screen.dart';
import 'package:stylerstack/views/home/home_screen.dart';
import 'package:stylerstack/views/home/splash_screen.dart';
import 'package:stylerstack/providers/auth_provider.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authProvider.isLoading;
      final isLoggedIn = authProvider.user != null;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnRegister = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/';

      //  Wait for auth state to be determined before redirecting
      if (isLoading) return isSplash ? null : '/';

      // 👇 Not logged in and not already on login/register
      if (!isLoggedIn && !isOnLogin && !isOnRegister) {
        return '/login';
      }

      // 👇 Already logged in but trying to access auth routes
      if (isLoggedIn && (isOnLogin || isOnRegister || isSplash)) {
        return '/home';
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) =>
            _customPageTransition(const RegistrationScreen(key: ValueKey('register'))),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _customPageTransition(const LoginScreen(key: ValueKey('login'))),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            _customPageTransition(const HomeScreen()),
      ),
    ],
  );
}


Page _customPageTransition(Widget child) {
  return CustomTransitionPage(
    transitionDuration: const Duration(milliseconds: 500),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // Slide from right
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      final tween = Tween(begin: begin, end: end)
          .chain(CurveTween(curve: curve));

      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
