import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/widgets/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          mode: AuthMode.login,
          switchScreen: () => context.go('/register'),
          login: authProvider.signIn,
          register: authProvider.signUp,
          onGoogleSignIn: authProvider.signInWithGoogle,
        ),
    );
  }
}
