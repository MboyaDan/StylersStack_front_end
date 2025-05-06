import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
//applying connectivity and internet checker for internet checking
class ConnectivityService {
  final StreamController<bool> _internetStatusController = StreamController<bool>.broadcast();
  Stream<bool> get internetStatusStream => _internetStatusController.stream;

  ConnectivityService() {
    // Listen to connectivity changes (WiFi/Mobile)
    Connectivity().onConnectivityChanged.listen((_) async {
      final hasInternet = await InternetConnectionChecker.instance.hasConnection;
      _internetStatusController.add(hasInternet);
    });

    // Listen to actual internet availability
    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;
      _internetStatusController.add(connected);
    });
  }

  void dispose() {
    _internetStatusController.close();
  }
}
