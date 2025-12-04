import 'package:flutter/material.dart';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/model/models/venue.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'package:flutterapp/model/repositories/venue_repository_imp.dart';

class EventsAtVenueVm extends ChangeNotifier {
  final Venue venue;
  final EventRepositoryImplementation _eventRepository;

  bool _loading = true;
  List<Event> _events = [];
  String? _error;

  bool get isLoading => _loading;
  List<Event> get events => _events;
  String? get error => _error;

  EventsAtVenueVm({required this.venue})
      : _eventRepository = EventRepositoryImplementation(
    venueRepository: VenueRepositoryImplementation(),
  ) {
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      _loading = true;
      notifyListeners();

      final fetchedEvents = await _eventRepository.getByVenue(venue.id);

      fetchedEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

      _events = fetchedEvents;
      _error = null;
    } catch (e) {
      _error = "Failed to load events for this venue.";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
