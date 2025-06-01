import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/widgets/section_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        await context.read<AddressProvider>().fetchAddress(uid);
      }
    });
  }

  Future<void> _handleLogout(AuthProvider authProvider) async {
    setState(() => _isSigningOut = true);
    await authProvider.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final addressProvider = context.watch<AddressProvider>();

    final user = authProvider.user;
    final displayName = user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? 'No email';
    final currentAddress = addressProvider.address?.address;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: _isSigningOut
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// --- Profile Info Card ---
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// --- Shipping Address Section ---
            SectionCard(
              title: 'Shipping Address',
              action: TextButton(
                onPressed: () => context.push('/shipping-address'),
                child: const Text("Edit"),
              ),
              child: Text(
                currentAddress ?? 'No address saved yet. Add one now!',
                style: TextStyle(
                  color: currentAddress != null ? Colors.black87 : Colors.red,
                  fontStyle: currentAddress == null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Appearance',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),


            const SizedBox(height: 40),

            /// --- Logout Button ---
            ElevatedButton.icon(
              onPressed: _isSigningOut ? null : () => _handleLogout(authProvider),
              icon: const Icon(Icons.logout,
                color: AppColors.text,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.text,

                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: Colors.black45,
              ),
            )
          ],
        ),
      ),
    );
  }
}
