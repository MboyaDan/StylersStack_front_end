import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  Future<void> _handleLogout(AuthProvider authProvider) async {
    setState(() => _isSigningOut = true);

    await authProvider.signOut();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed:
            _isSigningOut ? null : () async => _handleLogout(authProvider),
          ),
        ],
      ),
      body: Center(
        child: _isSigningOut
            ? const CircularProgressIndicator()
            : const Text(
          'Welcome to StylerStack!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
