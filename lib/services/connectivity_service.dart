import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final _internetStatusController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _checkInitialConnection(); // Check once on service start

    // Listen for network (Wi-Fi/Mobile) changes
    Connectivity().onConnectivityChanged.listen((_) async {
      final hasInternet = await InternetConnectionChecker.instance.hasConnection;
      _internetStatusController.add(hasInternet);
    });

    // Listen for actual internet availability (ping test)
    InternetConnectionChecker.instance.onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;
      _internetStatusController.add(connected);
    });
  }

  Stream<bool> get internetStatusStream => _internetStatusController.stream;

  void _checkInitialConnection() async {
    final hasInternet = await InternetConnectionChecker.instance.hasConnection;
    _internetStatusController.add(hasInternet);
  }

  void dispose() {
    _internetStatusController.close();
  }
}
