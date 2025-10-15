import 'package:flutter/foundation.dart';
import '../../domain/events/event.dart';
import '../../domain/venues/venue.dart';
import '../../data/venues/venue_repository_firestore.dart';

class EventSliderVm extends ChangeNotifier {
  final Event event;
  final VenueRepositoryFirestore _venueRepo;

  EventSliderVm({
    required this.event,
    VenueRepositoryFirestore? venueRepo,
  }) : _venueRepo = venueRepo ?? VenueRepositoryFirestore() {
    _init();
  }

  bool _loading = true;
  String? _error;
  Venue? _venue;

  bool get isLoading => _loading;
  String? get error => _error;
  Venue? get venue => _venue;
  bool get isReady => !_loading && _error == null && _venue != null;

  Future<void> _init() async {
    try {
      _loading = true;
      notifyListeners();

      _venue = await _venueRepo.getOne(event.venueId);

      _error = null;
    } catch (e) {
      _error = 'Failed to load venue: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
