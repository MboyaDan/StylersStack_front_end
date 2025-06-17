import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stylerstack/providers/notification_provider.dart';

class FCMInitializer extends StatefulWidget {
  final Widget child;

  const FCMInitializer({super.key, required this.child});

  @override
  State<FCMInitializer> createState() => _FCMInitializerState();
}

class _FCMInitializerState extends State<FCMInitializer> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      notifProvider.initFCM();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
