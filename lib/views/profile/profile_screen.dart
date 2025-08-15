import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/address_provider.dart';
import '../../utils/constants.dart';

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
    final displayName = user?.email.split('@').first ?? 'User';
    final email = user?.email ?? 'No email';
    final currentAddress = addressProvider.address?.address;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: _isSigningOut
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          // ===== Profile Header =====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20), // Using your static constant
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor:AppColors.background,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Track My Orders button
                ElevatedButton.icon(
                  onPressed: () => context.push('/orders'),
                  icon: const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.text,
                    size: 26,
                  ),

                  label: const Text(
                    "Track My Orders",
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 20),

          // ===== Settings Section =====
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Shipping Address'),
            subtitle: Text(
              currentAddress ?? 'No address saved yet. Add one now!',
              style: TextStyle(
                color: currentAddress != null ? Colors.black87 : Colors.red,
                fontStyle:
                currentAddress == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/shipping-address'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ),
          const Divider(),

          // ===== Logout Button =====
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _isSigningOut
                ? null
                : () => _handleLogout(authProvider),
          ),
        ],
      ),
    );
  }
}
