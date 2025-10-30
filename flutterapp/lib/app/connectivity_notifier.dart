import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityNotifier extends ChangeNotifier {
  late final StreamSubscription<InternetStatus> _subscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityNotifier() {
    _subscription =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
          final hasConnection = (status == InternetStatus.connected);

          if (hasConnection != _isConnected) {
            _isConnected = hasConnection;
            notifyListeners();
          }
        });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
