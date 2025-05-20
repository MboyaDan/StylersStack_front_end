import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  //fetch the address when the screen loads

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if  (mounted ) {
      await context.read<AddressProvider>().fetchAddress();
      }
    });
  }
  //manage memory leaks
  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Access provider BEFORE the async gap
      final addressProvider = context.read<AddressProvider>();

      await addressProvider.editAddress(_addressController.text);

      if (!mounted) return;

      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();
    final currentAddress = addressProvider.address?.address??'No address saved yet';

    return Scaffold(
      appBar: AppBar(title: const Text("Shipping Address")),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
              "Current Address:",
              style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
          ),
              Text(
                currentAddress,
              style: const TextStyle(fontSize: 16,color:Colors.black54),),
              const SizedBox(height: 20),
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
              _isLoading
              ?const CircularProgressIndicator()
              :ElevatedButton(
                onPressed: () => _saveAddress,
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
