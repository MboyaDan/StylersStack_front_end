import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/widgets/auth_form.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        body: AuthForm(
          mode: AuthMode.register,
          switchScreen: () => context.go('/login'),
          login: authProvider.signIn,
          register: authProvider.signUp,
          onGoogleSignIn: authProvider.signInWithGoogle,
        ),
    );
  }
}
