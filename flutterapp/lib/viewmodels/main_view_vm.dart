import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MainViewVm extends ChangeNotifier {
  LatLng? _currentPosition;
  bool _loading = true;
  String? _errorMessage;

  LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  MainViewVm() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      _loading = true;
      notifyListeners();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();

      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = 'Could not get location: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
