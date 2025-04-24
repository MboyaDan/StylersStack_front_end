import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:stylerstack/models/category_type.dart';
import 'package:stylerstack/views/auth/login_screen.dart';
import 'package:stylerstack/views/auth/registration_screen.dart';
import 'package:stylerstack/views/category/Category_Product_Screen.dart';
import 'package:stylerstack/views/home/home_screen.dart';
import 'package:stylerstack/views/home/splash_screen.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/views/product/ProductListScreen.dart';

import '../models/product_model.dart';
import '../views/cart/checkout_screen.dart';
import '../views/cart/my_cart_screen.dart';
import '../views/cart/payment_method.dart';
import '../views/cart/payment_success_screen.dart';
import '../views/cart/shipping_address.dart';
import '../views/product/product_details.dart';

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

      //  Not logged in and not already on login/register
      if (!isLoggedIn && !isOnLogin && !isOnRegister) {
        return '/login';
      }

      //  Already logged in but trying to access auth routes
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
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product-details',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailsPage(product: product);
        },
      ),

      //  Cart
      GoRoute(
        path: '/cart',
        pageBuilder: (context, state) =>
            _customPageTransition(const MyCartScreen()),
      ),

      //  Checkout
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            _customPageTransition(const CheckoutScreen()),
      ),

      //  Shipping Address
      GoRoute(
        path: '/shipping-address',
        pageBuilder: (context, state) =>
            _customPageTransition(const ShippingAddressScreen()),
      ),

      // Payment Method
      GoRoute(
        path: '/payment-method',
        pageBuilder: (context, state) =>
            _customPageTransition(const PaymentMethodScreen()),
      ),

      //  Success
      GoRoute(
        path: '/payment-success',
        pageBuilder: (context, state) =>
            _customPageTransition(const PaymentSuccessScreen()),
      ),
      GoRoute(path: '/category-products',
        builder: (context,state){
        final category = state.extra as CategoryType;
        return CategoryProductScreen(category: category);
        },
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
