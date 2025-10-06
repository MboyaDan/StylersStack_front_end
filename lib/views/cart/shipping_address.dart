import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:stylerstack/widgets/appsnackwidget.dart';
import '../../providers/auth_provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider = context.read<AuthProvider>();
        final uid = authProvider.user?.uid;
        if (uid != null) {
          final provider = context.read<AddressProvider>();
          await provider.fetchAddress(uid);
          if (mounted) {
            _addressController.text = provider.address?.address ?? '';
          }
        } else {
          throw 'User not logged in';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch address: $e')),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final addressProvider = context.read<AddressProvider>();
      final uid = context.read<AuthProvider>().user?.uid;

      try {
        if (uid != null) {
          await addressProvider.editAddress(_addressController.text, uid);
          if (!mounted) return;
          AppSnackbar.show(
            context,
            message: 'Address added successfully',
            type: SnackbarType.success,
          );

          Navigator.pop(context);
        } else {
          throw 'User ID not found';
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save address: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final currentAddress = addressProvider.address?.address ?? 'No address saved yet';

    return Scaffold(
      appBar: AppBar(title: const Text("Shipping Address")),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Current Address:",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(currentAddress,
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: "Enter your address",
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                  prefixIcon: Icon(Icons.location_on),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown, width: 2),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter your address" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button2,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child:Text("Save Address",
                    style: TextStyle(
                        color: AppColors.text(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
