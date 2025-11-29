import 'package:flutter/foundation.dart';
import '../../domain/useCases/useCase_create_booked.dart';
import '../../model/models/event.dart';
import '../../model/models/venue.dart';
import '../../model/repositories/booked_repository_imp.dart';
import '../../model/repositories/event_repository_imp.dart';
import '../../model/repositories/user_repository_imp.dart';
import '../../model/repositories/venue_repository_imp.dart';

class EventSliderVm extends ChangeNotifier {
  final Event event;
  final VenueRepositoryImplementation _venueRepo;
  final CreateBookingUseCase _createBookingUseCase;
  final BookedEventRepositoryImplementation _bookedRepo;

  EventSliderVm({
    required this.event,
    required String? currentUserId,
    VenueRepositoryImplementation? venueRepo,
  })  : _venueRepo = venueRepo ?? VenueRepositoryImplementation(),
        _bookedRepo = BookedEventRepositoryImplementation(),
        _createBookingUseCase = CreateBookingUseCase(
          bookedEventRepository: BookedEventRepositoryImplementation(),
          userRepository: UserRepositoryImplementation(),
          eventRepository: EventRepositoryImplementation(
            venueRepository: venueRepo ?? VenueRepositoryImplementation(),
          ),
        ) {
    _init(currentUserId);
  }

  bool _isReserved = false;
  bool _isOrganizer = false;
  bool get isReserved => _isReserved;
  bool get isOrganizer => _isOrganizer;

  bool _loading = true;
  String? _error;
  Venue? _venue;
  bool _isBooking = false;

  bool get isLoading => _loading;
  String? get error => _error;
  Venue? get venue => _venue;
  bool get isBooking => _isBooking;

  Future<void> _init(String? currentUserId) async {
    try {
      _loading = true;
      notifyListeners();

      _venue = await _venueRepo.getOne(event.venueId);

      if (currentUserId != null && currentUserId == event.organizerId) {
        _isOrganizer = true;
        _isReserved = false;
      }

      else if (currentUserId != null) {
        _isOrganizer = false;
        _isReserved = await _bookedRepo.isEventBookedByUser(userId: currentUserId, eventId: event.id);
      }

      else {
        _isOrganizer = false;
        _isReserved = false;
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load event details: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> handleBooking(String? userId) async {
    if (isReserved) {
      await cancelBooking(userId);
    } else {
      await createBooking(userId);
    }
  }

  Future<void> createBooking(String? userId) async {
    _isBooking = true;
    _error = null;
    notifyListeners();

    final result = await _createBookingUseCase.execute(
      userId: userId,
      eventId: event.id,
    );

    if (result.success) {
      _isReserved = true;
    } else {
      _error = result.errorMessage;
    }

    _isBooking = false;
    notifyListeners();
  }

  Future<void> cancelBooking(String? userId) async {
    if (userId == null) {
      _error = "User not logged in.";
      notifyListeners();
      return;
    }
    _isBooking = true;
    _error = null;
    notifyListeners();

    try {
      await _bookedRepo.cancelByUserIdAndEventId(userId: userId, eventId: event.id);
      _isReserved = false;
    } catch (e) {
      _error = "Failed to cancel booking. Please try again.";
    }

    _isBooking = false;
    notifyListeners();
  }
}
