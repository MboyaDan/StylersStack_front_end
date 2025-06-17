import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

enum AuthMode {
  login,
  register,
}

class AuthForm extends StatefulWidget {
  final AuthMode mode;
  final VoidCallback switchScreen;
  final Future<String?> Function(String email, String password) login;
  final Future<String?> Function(String email, String password) register;
  final Future<String?> Function()? onGoogleSignIn;

  const AuthForm({
    required this.mode,
    required this.switchScreen,
    required this.login,
    required this.register,
    this.onGoogleSignIn,
    Key? key,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _controller.forward(from: 0);
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    _clearError();

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String? error;
    if (widget.mode == AuthMode.login) {
      error = await widget.login(email, password);
    } else {
      error = await widget.register(email, password);
    }
    if (!mounted) return; // Check if the context is still valid before navigating

    setState(() => _isLoading = false);

    if (error != null) {
      _showError(error);
    } else if (context.mounted) {
      context.go('/home');
    }
  }

  void _googleSignIn() async {
    if (widget.onGoogleSignIn == null) return;

    setState(() => _isGoogleLoading = true);
    _clearError();

    String? error = await widget.onGoogleSignIn!();
    if (!mounted) return; // Check if the context is still valid before navigating)

    setState(() => _isGoogleLoading = false);

    if (error != null) {
      _showError(error);
    } else if (context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.mode == AuthMode.login;

    return Container(
      color: const Color(0xFFE5E5E5), // Background color
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "StylerStack",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: -0.5, end: 0),

              const SizedBox(height: 10),

              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLogin ? "Login" : "Register",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email, color: Colors.brown),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Enter your email";
                            if (!RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$").hasMatch(value)) {
                              return "Invalid email format";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock, color: Colors.brown),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.brown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) return "Password must be at least 6 characters";
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          )
                              .animate(controller: _controller)
                              .shake(duration: 500.ms, hz: 5)
                              .fadeOut(duration: 3.seconds, delay: 3.seconds),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading ? Colors.brown.shade200 : Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                          )
                              : Text(isLogin ? "Login" : "Register", style: const TextStyle(fontSize: 16)),
                        ),

                        const SizedBox(height: 10),

                        if (widget.onGoogleSignIn != null)
                          _isGoogleLoading
                              ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.brown)
                              .animate()
                              .rotate(duration: 1.seconds)
                              .scale(delay: 200.ms)
                              : OutlinedButton.icon(
                            onPressed: _googleSignIn,
                            icon: const Icon(Icons.login, color: Colors.brown),
                            label: const Text(
                              "Sign in with Google",
                              style: TextStyle(color: Colors.brown),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.brown),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: widget.switchScreen,
                          child: Text(
                            isLogin ? "Don’t have an account? Register" : "Already have an account? Login",
                            style: const TextStyle(color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: 0.5, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}
