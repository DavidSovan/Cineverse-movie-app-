import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late StreamSubscription _subscription;
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance();

  ConnectivityProvider() {
    _initialize();
  }

  void _initialize() {
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      final hasConnection = await _connectionChecker.hasConnection;
      _isOnline = hasConnection;
      notifyListeners();
    });

    // Initial check
    _connectionChecker.hasConnection.then((value) {
      _isOnline = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
