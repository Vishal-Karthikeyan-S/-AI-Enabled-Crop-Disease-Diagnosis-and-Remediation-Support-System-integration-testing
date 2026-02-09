import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isOnline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool get isOnline => _isOnline;
  ConnectivityResult get connectivityResult => _connectivityResult;

  ConnectivityProvider() {
    _initConnectivity();
    _listenToConnectivityChanges();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get connectivity: $e');
      }
      _connectivityResult = ConnectivityResult.none;
      _isOnline = false;
    }
    notifyListeners();
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectionStatus(result);
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) {
          print('Connectivity error: $error');
        }
      },
    );
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectivityResult = result;
    _isOnline = result != ConnectivityResult.none;

    if (kDebugMode) {
      print('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      print('Result: $result');
    }
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to check connectivity: $e');
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
