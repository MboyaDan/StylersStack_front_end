import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:stylerstack/utils/constants.dart';
import 'package:vibration/vibration.dart';
import 'package:stylerstack/widgets/payment_processing_dialog.dart';

class PaymentUIService {
  static VoidCallback? paymentTimeoutCallback;
  static int retryAttempts = 0;
  static const int maxRetryAttempts = 3;

  static Future<void> showProcessingDialog(BuildContext context, double amount) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentProcessingDialog(amount: amount),
    );
  }

  static void closeDialogIfOpen(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static Future<void> showRetryDialog(
      BuildContext context,
      double amount,
      Future<void> Function() onRetry,
      ) async {
    if (retryAttempts >= maxRetryAttempts) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Too Many Attempts'),
          content: const Text(
            'You’ve reached the maximum number of retry attempts.\nPlease try again later or contact support.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    await FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false,
      volume: 0.8,
    );

    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 400);
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Payment Delay'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attempt ${retryAttempts + 1} of $maxRetryAttempts',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your Ksh $amount payment confirmation is delayed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Would you like to retry the payment?',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              retryAttempts++;
              Navigator.of(ctx).pop();
              await onRetry();
            },
            child: const Text('Retry Payment'),
          ),
        ],
      ),
    );
  }

  static void resetRetryAttempts() {
    retryAttempts = 0;
  }

}

