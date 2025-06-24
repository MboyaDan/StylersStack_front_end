import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:stylerstack/services/notification_service.dart';
import 'package:stylerstack/services/payment_ui_service.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService;
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationProvider(ApiService apiService, this.navigatorKey)
      : _notificationService = NotificationService(apiService);

  bool _hasNavigatedToSuccess = false;

  bool get hasNavigatedToSuccess => _hasNavigatedToSuccess;

  void markNavigatedToSuccess() {
    _hasNavigatedToSuccess = true;
    notifyListeners();
  }

  void resetNavigatedToSuccess() {
    _hasNavigatedToSuccess = false;
    notifyListeners();
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

      _handlePaymentStatus(message);
    });
  }

  void _handleBackgroundMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handlePaymentStatus(message);
    });
  }

  Future<void> _handlePaymentStatus(RemoteMessage message) async {
    final data = message.data;
    final orderId = data['order_id'];
    final status = data['status'];
    final context = navigatorKey.currentContext;

    if (context == null || orderId == null || status == null) return;

    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Update payment status internally
    paymentProvider.updatePaymentStatusFromFCM(orderId, status);

    //  Close the payment dialog if it's open
    PaymentUIService.closeDialogIfOpen(context);

    //  Handle based on status
    switch (status.toLowerCase()) {
      case 'success':
        if (!_hasNavigatedToSuccess) {
          markNavigatedToSuccess();
          await cartProvider.clearCart();

          if (context.mounted) {
            GoRouter.of(context).go('/payment-success');
          }
        }
        break;

      case 'failed':
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment failed. Please try again.')),
          );
        }
        break;

      default:
        debugPrint('Unknown payment status received: $status');
        break;
    }
  }
}
