import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool hasInternet;
  final VoidCallback? onRetry;

  const ConnectivityBanner({
    super.key,
    required this.hasInternet,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: hasInternet ? -80 : 20,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: hasInternet ? 0 : 1,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Colors.red.shade600,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 10),
                const Text(
                  'No internet connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

  }
}
