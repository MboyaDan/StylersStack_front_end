import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/views/cart/my_cart_screen.dart';
import 'package:stylerstack/views/favorite/favorite_screen.dart';
import 'package:stylerstack/views/home/home_main_screen.dart';
import 'package:stylerstack/views/profile/profile_screen.dart';
import 'package:stylerstack/views/reels/reels_screen.dart';
import 'package:stylerstack/widgets/badgewidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    final List<Widget> _screens = [
      const HomeMainScreen(),
      ReelsScreen(products: productProvider.products),
      const MyCartScreen(),
      const FavoriteScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.brown,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: IconBadge(
              icon: const Icon(Icons.shopping_cart),
              count: context.watch<CartProvider>().cartCount,
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: IconBadge(
              icon: const Icon(Icons.favorite),
              count: context.watch<FavoriteProvider>().favoriteCount,
            ),
            label: 'Favorite',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
