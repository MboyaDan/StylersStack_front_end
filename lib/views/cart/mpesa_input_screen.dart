import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/payment_provider.dart';

class MpesaPhoneInputScreen extends StatefulWidget {
  const MpesaPhoneInputScreen({super.key});

  @override
  State<MpesaPhoneInputScreen> createState() => _MpesaPhoneInputScreenState();
}

class _MpesaPhoneInputScreenState extends State<MpesaPhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existingPhone = context.read<PaymentProvider>().phoneNumber;
    if (existingPhone != null && existingPhone.length == 9) {
      _controller.text = existingPhone;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitPhoneNumber() {
    if (_formKey.currentState!.validate()) {
      context.read<PaymentProvider>().setPhoneNumber(_controller.text.trim());
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter M-Pesa Number")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("We'll send an M-Pesa STK push to this number."),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixText: '+254 ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter phone number';
                  } else if (value.trim().length != 9 || !RegExp(r'^[17]\d{8}$').hasMatch(value.trim())) {
                    return 'Enter a valid Safaricom number (e.g. 712345678)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPhoneNumber,
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
