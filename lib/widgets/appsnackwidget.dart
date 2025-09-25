import 'package:flutter/material.dart';
import 'package:stylerstack/utils/constants.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  static void show(
      BuildContext context, {
        required String message,
        SnackbarType type = SnackbarType.info,
        String? actionLabel,
        VoidCallback? onAction,
        Duration duration = const Duration(seconds: 3),
      }) {
    final backgroundColor = _getBackgroundColor(context, type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        )
            : null,
      ),
    );
  }

  static Color _getBackgroundColor(BuildContext context, SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green[700]!;
      case SnackbarType.error:
        return Colors.red[700]!;
      case SnackbarType.warning:
        return Colors.orange[800]!;
      case SnackbarType.info:
      default:
        return AppColors.primary(context); // ✅ requires context
    }
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
      default:
        return Icons.info;
    }
  }
}
