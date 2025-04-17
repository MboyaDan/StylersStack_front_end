import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_rounded,
              size: 80,
              color: Colors.brown,
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 20),

            Text(
              "StylerStack",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutQuart),

            const SizedBox(height: 12),

            Text(
              "Style meets simplicity",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ).animate().fadeIn(delay: 1.seconds),

            const SizedBox(height: 30),

            if (isLoading)
              const CircularProgressIndicator(
                color: Colors.brown,
              ),
          ],
        ),
      ),
    );
  }
}
