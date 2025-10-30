import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../model/models/event.dart';
import '../../model/models/user.dart';
import '../../model/repositories/booked_repository_imp.dart';
import '../../model/repositories/event_repository_imp.dart';
import '../../model/repositories/user_repository_imp.dart';
import '../../model/repositories/venue_repository_imp.dart';
import '../../model/serviceAdapters/auth_adapter.dart';

enum ProfileState { loading, ready, notConfigured, error }

class ProfileViewVm extends ChangeNotifier {
  final UserRepositoryImplementation _userRepository;
  final BookedEventRepositoryImplementation _bookedRepository;
  final EventRepositoryImplementation _eventRepository;
  final AuthService _authService;

  final String _userId;

  User? _user;
  List<Event> _upcomingEvents = [];
  List<Event> _postedEvents = [];
  ProfileState _state = ProfileState.loading;
  String? _errorMessage;

  User? get user => _user;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get postedEvents => _postedEvents;
  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;

  ProfileViewVm(this._userId)
      : _userRepository = UserRepositoryImplementation(),
        _bookedRepository = BookedEventRepositoryImplementation(),
        _eventRepository = EventRepositoryImplementation(venueRepository: VenueRepositoryImplementation()),
        _authService = AuthService() {
    loadData();
  }

  Future<void> signOut() async {

    await _authService.signOut();
  }

  Future<void> loadData() async {
    try {
      _state = ProfileState.loading;
      notifyListeners();

      _user = await _userRepository.getOne(_userId);

      if (_user == null) {
        _state = ProfileState.error;
        _errorMessage = "User not found.";
      } else if (_user!.username == null || _user!.username!.isEmpty) {
        _state = ProfileState.notConfigured;
      } else {
        await _fetchUserEvents();
        _state = ProfileState.ready;
      }
    } catch (e) {
      _state = ProfileState.error;
      _errorMessage = "An error occurred while fetching data: $e";
    } finally {
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  Future<void> _fetchUserEvents() async {
    final bookings = await _bookedRepository.getBookingsForUser(_userId);
    final upcomingEventIds = bookings.map((b) => b.eventId).toList();

    if (upcomingEventIds.isNotEmpty) {
      final events = <Event>[];
      for (var eventId in upcomingEventIds) {
        final event = await _eventRepository.getOne(eventId);
        if (event != null) {
          events.add(event);
        }
      }
      events.sort((a, b) => a.startTime.compareTo(b.startTime));
      _upcomingEvents = events;
    } else {
      _upcomingEvents = [];
    }

    _postedEvents = await _eventRepository.getByOrganizer(_userId);
    _postedEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void navigateToConfiguration(BuildContext context) {
    if (_user != null) {
      context.push('/profile_update_view', extra: _user).then((result) {
        if (result == true) {
          loadData();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot open configuration: User data is missing.")),
      );
    }
  }
}
