import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Monitors network connectivity and notifies listeners
class ConnectivityService extends ChangeNotifier {
  bool _isOnline = false;
  StreamSubscription<ConnectivityResult>? _subscription;

  bool get isOnline => _isOnline;

  /// Initialize the connectivity listener
  Future<void> init() async {
    // Check initial status
    final result = await Connectivity().checkConnectivity();
    _isOnline = result != ConnectivityResult.none;

    // Listen for changes
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();

      if (wasOffline && _isOnline) {
        // Connection restored — trigger sync via provider
        onConnectivityRestored?.call();
      }
    });
  }

  /// Callback triggered when connectivity is restored
  VoidCallback? onConnectivityRestored;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

