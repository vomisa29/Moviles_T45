import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../data/events/event_repository_firestore.dart';
import 'package:flutter/material.dart';

class MainViewVm extends ChangeNotifier {
  final EventRepositoryFirestore _eventRepository = EventRepositoryFirestore();
  LatLng? _currentPosition;
  bool _loading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;

  LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  Set<Marker> get markers => _markers;

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

      await _loadCustomPin();
      await _loadNearbyEvents();
    } catch (e) {
      _errorMessage = 'Could not get location: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<void> _loadCustomPin() async {
    _customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(64, 64)),
      'lib/assets/Logo_app_SportLink_Small.png',
    );
  }

  Future<void> _loadNearbyEvents() async {
    if (_currentPosition == null) return;

    try {
      final events = await _eventRepository.getNearby(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 10.0,
      );

      _markers = events.map((event) {
        if (event.latitude == null || event.longitude == null) return null;
        return Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          infoWindow: InfoWindow(title: event.name),
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
        );
      }).whereType<Marker>().toSet();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading nearby events: $e';
      notifyListeners();
    }
  }
}
