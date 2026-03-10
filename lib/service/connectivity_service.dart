import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool> _connectivityStreamController = StreamController<bool>.broadcast();

  Stream<bool> get connectivityStream => _connectivityStreamController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Future<void> initialize() async {
    // Initial check
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Subscribe to changes
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // Treat any result other than none as online for simple logic
    bool online = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    if (_isOnline != online) {
      _isOnline = online;
      _connectivityStreamController.add(_isOnline);
    }
  }

  void dispose() {
    _connectivityStreamController.close();
  }
}
