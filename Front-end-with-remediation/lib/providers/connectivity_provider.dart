import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ConnectivityProvider with ChangeNotifier {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isOnline = false;
  bool _isServerReachable = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _heartbeatTimer;
  final String baseUrl;

  bool get isNetworkOn => _isOnline;
  bool get isServerAvailable => _isServerReachable;
  bool get isOnline => _isOnline && _isServerReachable;
  ConnectivityResult get connectivityResult => _connectivityResult;

  ConnectivityProvider({this.baseUrl = 'http://127.0.0.1:8001'}) {
    _initConnectivity();
    _listenToConnectivityChanges();
    _startHeartbeat();
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
    }
    
    // Always check server reachability at startup
    await _checkServerReachability();
    notifyListeners();
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        _updateConnectionStatus(result);
        if (_isOnline) {
          await _checkServerReachability();
        } else {
          _isServerReachable = false;
        }
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) {
          print('Connectivity error: $error');
        }
      },
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // Check reachability every 15 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      // On Web, we ALWAYS check reachability because the browser network status is unreliable
      if (_isOnline || kIsWeb) {
        await _checkServerReachability();
      }
    });
  }

  Future<void> _checkServerReachability() async {
    try {
      // Check Backend Server directly — this is the most reliable indicator
      final response = await http.get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      
      final isBackEndAlive = response.statusCode == 200;
      
      final previousServerState = _isServerReachable;
      final previousOnlineState = _isOnline;

      _isServerReachable = isBackEndAlive;
      
      // On Web, if we can reach the backend, we are online.
      // The previous google.com check was blocked by CORS on Web browsers.
      if (kIsWeb) {
        _isOnline = isBackEndAlive;
      }

      if (previousServerState != _isServerReachable || previousOnlineState != _isOnline) {
        if (kDebugMode) {
          print('Connectivity update: online=$_isOnline, server=$_isServerReachable');
        }
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Connectivity Check Failed for $baseUrl/health: ${e.toString()}');
      }
      if (_isServerReachable || _isOnline) {
        _isServerReachable = false;
        // Only set offline on web if server is truly unreachable
        if (kIsWeb) {
          _isOnline = false;
        }
        notifyListeners();
      }
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectivityResult = result;
    
    // On web, ConnectivityResult.none is often unreliable.
    // We treat it as a hint, but if we are already 'Online' via server check, we stay Online.
    final bool networkDetected = result != ConnectivityResult.none;
    
    if (kIsWeb) {
      // On web, we are 'online' if either a network is detected OR the server was previously reachable
      _isOnline = networkDetected || _isServerReachable;
    } else {
      _isOnline = networkDetected;
    }

    if (kDebugMode) {
      print('Connectivity changed: status=$_isOnline (Internal: $result, ServerReachable: $_isServerReachable)');
    }
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
      await _checkServerReachability();
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
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}
