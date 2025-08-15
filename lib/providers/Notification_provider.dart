import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/main.dart';

import 'package:stylerstack/models/order_model.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/providers/order_provider.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:stylerstack/services/notification_service.dart';
import 'package:stylerstack/services/payment_ui_service.dart';
import 'package:stylerstack/utils/error_parser.dart';
import 'package:stylerstack/widgets/appsnackwidget.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService;
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationProvider(ApiService apiService, this.navigatorKey)
      : _notificationService = NotificationService(apiService);

  bool _hasNavigatedToSuccess = false;
  final Set<String> _processedPaymentIds = {};

  bool get hasNavigatedToSuccess => _hasNavigatedToSuccess;

  void markNavigatedToSuccess() {
    _hasNavigatedToSuccess = true;
    notifyListeners();
  }

  void resetNavigatedToSuccess() {
    _hasNavigatedToSuccess = false;
    notifyListeners();
  }

  static void resetFlag([BuildContext? context]) {
    BuildContext? ctx = context ?? globalNavigatorKey.currentContext;

    if (ctx == null) {
      debugPrint("❌ No valid BuildContext found to access NotificationProvider.");
      return;
    }

    try {
      Provider.of<NotificationProvider>(ctx, listen: false).resetNavigatedToSuccess();
    } catch (e, stack) {
      debugPrint("❌ Failed to access NotificationProvider: $e");
      debugPrint("$stack");
    }
  }




  Future<void> initFCM() async {
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _setupLocalNotifications();
      await _setupToken();
      _handleForegroundMessages();
      _handleBackgroundMessages();
    }
  }

  Future<void> _setupToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _notificationService.sendTokenToBackend(token);
    }
    _messaging.onTokenRefresh.listen((newToken) async {
      await _notificationService.sendTokenToBackend(newToken);
    });
  }

  Future<void> _setupLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (details) {
        // Optional: handle tap on notification
      },
    );
  }

  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        await _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }

      await _handlePaymentStatus(message);
    });
  }

  void _handleBackgroundMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handlePaymentStatus(message);
    });
  }

  Future<void> _handlePaymentStatus(RemoteMessage message) async {
    debugPrint("📨 FCM Data Payload: ${message.data}");

    final data = message.data;
    final status = data['status'];
    final paymentId = data['payment_intent_id'];
    final totalAmount = double.tryParse(data['total_amount'] ?? '');
    final context = navigatorKey.currentContext;

    if (context == null || paymentId == null || status == null) return;

    // Prevent duplicate processing
    if (_processedPaymentIds.contains(paymentId)) {
      debugPrint("⚠️ Skipping duplicate FCM handling for paymentId: $paymentId");
      return;
    }
    _processedPaymentIds.add(paymentId);

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    paymentProvider.updatePaymentStatusFromFCM(paymentId, status);

    // Close payment dialog if it's open
    PaymentUIService.closeDialogIfOpen(context);

    // Cancel timeout handler if still pending
    if (PaymentUIService.paymentTimeoutCallback != null) {
      debugPrint("🛑 Cancelling timeout callback...");
      PaymentUIService.paymentTimeoutCallback?.call();
      PaymentUIService.paymentTimeoutCallback = null;
    }

    switch (status.toLowerCase()) {
      case 'succeeded':
        debugPrint("🟢 Payment succeeded signal received.");
        debugPrint("🔎 Already navigated? $_hasNavigatedToSuccess");
        debugPrint("🔎 PaymentId: $paymentId | TotalAmount: $totalAmount");

        if (!_hasNavigatedToSuccess && totalAmount != null) {
          try {
            final cartItems = cartProvider.cartItems.map((item) {
              debugPrint("🛒 Cart item: ${item.productName}, Qty: ${item.quantity}, Price: ${item.productPrice}");
              return OrderItem(
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.productPrice,
              );
            }).toList();

            final order = OrderModel(
              id: '',
              userUid: '',
              status: 'pending',
              createdAt: DateTime.now(),
              totalAmount: totalAmount,
              paymentId: paymentId,
              items: cartItems,
            );

            debugPrint("📤 Sending order to backend...");
            await orderProvider.createOrder(order);
            debugPrint("✅ Order created successfully.");

            await cartProvider.clearCart();
            debugPrint("🧹 Cart cleared.");

            markNavigatedToSuccess();
            debugPrint("🚀 Navigating to /payment-success...");

            if (context.mounted) {
              GoRouter.of(context).go('/payment-success');
              debugPrint("✅ Navigation triggered.");
            }
          } catch (e, stacktrace) {
            final errorMessage = ErrorUtils.parseDioError(e);

            if (errorMessage.contains("already exists")) {
              debugPrint("ℹ️ Order already exists. Navigating to success.");
              if (context.mounted) {
                GoRouter.of(context).go('/payment-success');
              }
              return;
            }

            debugPrint('❌ Order placement failed: $errorMessage');
            debugPrint('🪵 Stacktrace: $stacktrace');

            if (context.mounted) {
              AppSnackbar.show(
                context,
                message: errorMessage,
                type: SnackbarType.error,
              );
            }
          }
        }
        break;

      case 'failed':
        if (context.mounted) {
          AppSnackbar.show(
            context,
            message: 'Your payment was unsuccessful',
            type: SnackbarType.warning,
          );
        }
        break;

      default:
        debugPrint('❓ Unknown payment status received: $status');
        break;
    }
  }
}
