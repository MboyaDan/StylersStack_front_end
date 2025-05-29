import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/utils/constants.dart';

/// Wrap any subtree to automatically show SnackBars on login/logout.
class AuthFeedbackListener extends StatefulWidget {
  final Widget child;
  const AuthFeedbackListener({super.key, required this.child});

  @override
  State<AuthFeedbackListener> createState() => _AuthFeedbackListenerState();
}

class _AuthFeedbackListenerState extends State<AuthFeedbackListener> {
  AuthProvider? _auth;
  bool? _wasLoggedIn;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newAuth = context.read<AuthProvider>();

    // Attach listener only when AuthProvider instance changes
    if (!identical(newAuth, _auth)) {
      _auth?.removeListener(_handleAuthChange);
      _auth = newAuth;
      _wasLoggedIn = _auth!.isLoggedIn;
      _auth!.addListener(_handleAuthChange);
    }
  }

  void _handleAuthChange() {
    if (_auth == null) return;
    final isLoggedIn = _auth!.isLoggedIn;

    // First call after attach ⇒ no SnackBar
    if (_wasLoggedIn == null) {
      _wasLoggedIn = isLoggedIn;
      return;
    }

    if (isLoggedIn != _wasLoggedIn) {
      final msg  = isLoggedIn ? 'Welcome back!' : 'You’ve been logged out';
      //final icon = isLoggedIn ? Icons.login     : Icons.logout;
      _showSnack(msg);
      _wasLoggedIn = isLoggedIn;
    }
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context)
      ..clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _auth?.removeListener(_handleAuthChange);   // nullable safe
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
