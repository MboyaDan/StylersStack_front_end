import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool hasInternet;

  const ConnectivityBanner({super.key, required this.hasInternet});

  @override
  Widget build(BuildContext context) {
    if (hasInternet) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Center(
          child: Text(
            'No internet connection',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
