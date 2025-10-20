import 'package:flutter/foundation.dart';
import '../../model/models/event.dart';
import '../../model/models/venue.dart';
import '../../model/repositories/venue_repository_imp.dart';

class EventSliderVm extends ChangeNotifier {
  final Event event;
  final VenueRepositoryImplementation _venueRepo;

  EventSliderVm({
    required this.event,
    VenueRepositoryImplementation? venueRepo,
  }) : _venueRepo = venueRepo ?? VenueRepositoryImplementation() {
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
