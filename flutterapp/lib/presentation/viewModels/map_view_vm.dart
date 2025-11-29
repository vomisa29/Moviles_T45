import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../model/models/venue.dart';
import '../../model/repositories/event_repository_imp.dart';
import 'package:flutter/material.dart';
import '../../model/models/event.dart';
import '../../model/repositories/venue_repository_imp.dart';

enum EventFilterState { all, nearby }

class MapViewVm extends ChangeNotifier {
  late final EventRepositoryImplementation _eventRepository;
  late final VenueRepositoryImplementation _venueRepository;

  StreamSubscription<Position>? _positionStreamSubscription;

  LatLng? _currentPosition;
  bool _loading = true;
  String? _errorMessage;
  Set<Marker> _markers = {};
  BitmapDescriptor? _customIcon;

  List<Event> _allEvents = [];
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
    _eventRepository = EventRepositoryImplementation(venueRepository: _venueRepository);
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
      await _loadAllEventsAndVenues();

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
        _errorMessage = "Location permission is required to find nearby events.";
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = "Could not get current location.";
      return;
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

  Future<void> _loadAllEventsAndVenues() async {
    final results = await Future.wait([
      _eventRepository.getAll(),
      _venueRepository.getAll(),
    ]);
    _allEvents = results[0] as List<Event>;
    _allVenues = results[1] as List<Venue>;
  }

  void _updateMarkers() {
    List<Event> eventsToShow;
    if (_filterState == EventFilterState.nearby) {
      if (_currentPosition == null) {
        eventsToShow = [];
      } else {
        eventsToShow = _allEvents.where((event) {
          if (event.latitude == null || event.longitude == null) return false;
          final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            event.latitude!,
            event.longitude!,
          );
          return distance <= 10000;
        }).toList();
      }
    } else {
      eventsToShow = _allEvents;
    }
    _markers = eventsToShow.map((event) {
      if (event.latitude == null || event.longitude == null) return null;
      return Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude!, event.longitude!),
          infoWindow: InfoWindow(title: event.name),
          icon: _customIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => _onMarkerTap(event));
    }).whereType<Marker>().toSet();
  }

  Future<void> _onMarkerTap(Event event) async {
    _selectedEvent = event;
    notifyListeners();
  }

  Future<void> _loadCustomPin() async {
    _customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(64, 64)),
      'lib/assets/Logo_app_SportLink_Small.png',
    );
  }
}
