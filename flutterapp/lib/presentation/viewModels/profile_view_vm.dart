import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterapp/firebase_options.dart';
import '../../model/models/event.dart';
import '../../model/models/user.dart';
import '../../model/repositories/booked_repository_imp.dart';
import '../../model/repositories/event_repository_imp.dart';
import '../../model/repositories/user_repository_imp.dart';
import '../../model/repositories/venue_repository_imp.dart';
import '../../model/serviceAdapters/auth_adapter.dart';

class _IsolateArgs {
  final SendPort sendPort;
  final String userId;
  final RootIsolateToken rootIsolateToken;

  _IsolateArgs(this.sendPort, this.userId, this.rootIsolateToken);
}

class _EventFetchResult {
  final List<Event> upcomingEvents;
  final List<Event> postedEvents;
  _EventFetchResult(this.upcomingEvents, this.postedEvents);
}

Future<void> _isolateFetchEvents(_IsolateArgs args) async {

  BackgroundIsolateBinaryMessenger.ensureInitialized(args.rootIsolateToken);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final bookedRepository = BookedEventRepositoryImplementation();
  final eventRepository = EventRepositoryImplementation(venueRepository: VenueRepositoryImplementation());

  final bookings = await bookedRepository.getBookingsForUser(args.userId);
  final upcomingEventIds = bookings.map((b) => b.eventId).toList();

  List<Event> upcomingEvents = [];
  if (upcomingEventIds.isNotEmpty) {
    final events = <Event>[];
    for (var eventId in upcomingEventIds) {
      final event = await eventRepository.getOne(eventId);
      if (event != null) {
        events.add(event);
      }
    }
    events.sort((a, b) => a.startTime.compareTo(b.startTime));
    upcomingEvents = events;
  }

  final postedEvents = await eventRepository.getByOrganizer(args.userId);
  postedEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
  args.sendPort.send(_EventFetchResult(upcomingEvents, postedEvents));
}


enum ProfileState { loading, ready, notConfigured, error }

class ProfileViewVm extends ChangeNotifier {
  final UserRepositoryImplementation _userRepository;
  final AuthService _authService;
  final String _userId;

  User? _user;
  List<Event> _upcomingEvents = [];
  List<Event> _postedEvents = [];
  ProfileState _state = ProfileState.loading;
  String? _errorMessage;

  bool _isLoadingEvents = false;

  User? get user => _user;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get postedEvents => _postedEvents;
  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoadingEvents => _isLoadingEvents;

  ProfileViewVm(this._userId)
      : _userRepository = UserRepositoryImplementation(),
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
        _state = ProfileState.ready;
        notifyListeners();
        _fetchUserEventsWithIsolate();
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

  Future<void> _fetchUserEventsWithIsolate() async {
    _isLoadingEvents = true;
    notifyListeners();

    try {
      final receivePort = ReceivePort();

      final rootToken = RootIsolateToken.instance!;

      final args = _IsolateArgs(receivePort.sendPort, _userId, rootToken);

      await Isolate.spawn(_isolateFetchEvents, args);

      final result = await receivePort.first as _EventFetchResult;

      _upcomingEvents = result.upcomingEvents;
      _postedEvents = result.postedEvents;

    } catch (e) {
      debugPrint("Error fetching events in isolate: $e");
      _errorMessage = "Could not load event lists.";
      _upcomingEvents = [];
      _postedEvents = [];
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
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

