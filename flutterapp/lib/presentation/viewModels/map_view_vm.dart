import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../model/models/venue.dart';
import 'package:flutter/material.dart';
import '../../model/models/event.dart';
import '../../model/repositories/venue_repository_imp.dart';

enum EventFilterState { all, nearby }

class MapViewVm extends ChangeNotifier {
  late final VenueRepositoryImplementation _venueRepository;

  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng? _currentPosition;
  bool _loading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;
  List<Venue> _allVenues = [];
  Event? _selectedEvent;
  EventFilterState _filterState = EventFilterState.all;

  LatLng? get currentPosition => _currentPosition;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;
  Set<Marker> get markers => _markers;
  Event? get selectedEvent => _selectedEvent;
  List<Venue> get allVenues => _allVenues;
  EventFilterState get filterState => _filterState;

  MapViewVm() {
    _venueRepository = VenueRepositoryImplementation();
    _init();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void toggleEventFilter() {
    if (_filterState == EventFilterState.nearby) {
      _filterState = EventFilterState.all;
    } else {
      _filterState = EventFilterState.nearby;
    }
    _updateMarkers();
    notifyListeners();
  }

  void clearSelection() {
    _selectedEvent = null;
    notifyListeners();
  }

  Future<void> _init() async {
    try {
      _loading = true;
      notifyListeners();

      await _loadCustomPin();
      await _initializeLocationServices();
      await _loadAllVenues();

      if (_currentPosition != null) {
        _filterState = EventFilterState.nearby;
      }

      _updateMarkers();
    } catch (e) {
      _errorMessage = 'Initialization failed: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeLocationServices() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _errorMessage = "Location permission is required to find nearby venues.";
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = "Could not get current location.";
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position newPosition) {
        _currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
        if (_filterState == EventFilterState.nearby) {
          _updateMarkers();
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint("Error listening to location stream: $error");
      },
    );
  }

  Future<void> _loadAllVenues() async {
    _allVenues = await _venueRepository.getAll();
  }

  void _updateMarkers() {
    List<Venue> venuesToShow;
    if (_filterState == EventFilterState.nearby) {
      if (_currentPosition == null) {
        venuesToShow = [];
      } else {
        venuesToShow = _allVenues.where((venue) {
          final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            venue.latitude,
            venue.longitude,
          );
          return distance <= 10000;
        }).toList();
      }
    } else {
      venuesToShow = _allVenues;
    }

    _markers = venuesToShow.map((venue) {
      return Marker(
        markerId: MarkerId(venue.id),
        position: LatLng(venue.latitude, venue.longitude),
        infoWindow: InfoWindow(title: venue.name),
        icon: _customIcon ?? BitmapDescriptor.defaultMarker,
      );
    }).toSet();
  }

  Future<void> _loadCustomPin() async {
    _customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(64, 64)),
      'lib/assets/Logo_app_SportLink_Small.png',
    );
  }

  void setSelectedEvent(Event event) {
    _selectedEvent = event;
    notifyListeners();
  }
}

