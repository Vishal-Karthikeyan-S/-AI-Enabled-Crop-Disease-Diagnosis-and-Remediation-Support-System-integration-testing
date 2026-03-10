import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  final _controller = StreamController<ConnectivityResult>.broadcast();
  Stream<ConnectivityResult> get connectivityStream => _controller.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((result) {
      _controller.add(result);
    });
  }

  Future<bool> get isOnline async {
    var result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _controller.close();
  }
}
