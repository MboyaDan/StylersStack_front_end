import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _saveAddress(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Provider.of<CartProvider>(context, listen: false).setShippingAddress(_addressController.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Shipping Address")),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Enter your address",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter your address" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveAddress(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDCC6B0),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Address"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
