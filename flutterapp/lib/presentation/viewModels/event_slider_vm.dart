import 'package:flutter/foundation.dart';
import 'package:flutterapp/domain/useCases/useCase_get_affinity.dart';
import 'package:flutterapp/model/repositories/affinity_score_repository_imp.dart';import 'package:flutterapp/model/repositories/analytics_repositories/cancelation_repository_imp.dart';
import 'package:flutterapp/model/repositories/booked_repository_imp.dart';
import 'package:flutterapp/model/repositories/user_repository_imp.dart';
import '../../domain/useCases/useCase_create_booked.dart';
import '../../domain/useCases/useCase_delete_booked.dart';
import '../../model/models/event.dart';
import '../../model/models/venue.dart';
import '../../model/repositories/event_repository_imp.dart';
import '../../model/repositories/venue_repository_imp.dart';

class EventSliderVm extends ChangeNotifier {
  final Event event;
  final String? currentUserId;

  final VenueRepositoryImplementation _venueRepo;
  final BookedEventRepositoryImplementation _bookedRepo;

  final CreateBookingUseCase _createBookingUseCase;
  final DeleteBookingUseCase _deleteBookingUseCase;
  final GetAffinityUseCase _getAffinityUseCase;

  EventSliderVm({
    required this.event,
    required this.currentUserId,
  })  : _venueRepo = VenueRepositoryImplementation(),
        _bookedRepo = BookedEventRepositoryImplementation(),
        _getAffinityUseCase = GetAffinityUseCase(
          userRepository: UserRepositoryImplementation(),
          eventRepository: EventRepositoryImplementation(venueRepository: VenueRepositoryImplementation()),
          bookedRepository: BookedEventRepositoryImplementation(),
          affinityRepository: AffinityScoreRepositoryImp(),
        ),
        _createBookingUseCase = CreateBookingUseCase(
          bookedEventRepository: BookedEventRepositoryImplementation(),
          userRepository: UserRepositoryImplementation(),
          eventRepository: EventRepositoryImplementation(
            venueRepository: VenueRepositoryImplementation(),
          ),
          cancelationRepository: CancelationRepositoryImplementation(),
        ),
        _deleteBookingUseCase = DeleteBookingUseCase(
          bookedEventRepository: BookedEventRepositoryImplementation(),
          eventRepository: EventRepositoryImplementation(
            venueRepository: VenueRepositoryImplementation(),
          ),
          cancelationRepository: CancelationRepositoryImplementation(),
        ) {
    _init();
  }

  bool _isReserved = false;
  bool _isOrganizer = false;
  bool _loading = true;
  String? _error;
  Venue? _venue;
  bool _isBooking = false;
  double? _affinityScore;
  bool _isLoadingAffinity = false;

  bool get isReserved => _isReserved;
  bool get isOrganizer => _isOrganizer;
  bool get isLoading => _loading;
  String? get error => _error;
  Venue? get venue => _venue;
  bool get isBooking => _isBooking;
  double? get affinityScore => _affinityScore;
  bool get isLoadingAffinity => _isLoadingAffinity;

  Future<void> _init() async {
    try {
      _loading = true;
      notifyListeners();

      _venue = await _venueRepo.getOne(event.venueId);

      if (currentUserId != null && currentUserId == event.organizerId) {
        _isOrganizer = true;
        _isReserved = false;
      } else if (currentUserId != null) {
        _isOrganizer = false;
        _isReserved = await _bookedRepo.isEventBookedByUser(userId: currentUserId!, eventId: event.id);
      } else {
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

    if (currentUserId != null && !_isOrganizer) {
      _triggerAffinityCalculation();
    }
  }

  Future<void> _triggerAffinityCalculation() async {
    if (_isLoadingAffinity || currentUserId == null) return;

    _isLoadingAffinity = true;
    notifyListeners();

    try {
      final result = await _getAffinityUseCase.execute(
        userId: currentUserId!,
        targetEvent: event,
      );

      if (result.success && result.data != null) {
        _affinityScore = result.data as double;
      } else {
        debugPrint(result.errorMessage ?? "Unknown error from GetAffinityUseCase");
      }
    } catch (e) {
      debugPrint("Error triggering affinity score calculation: $e");
    } finally {
      _isLoadingAffinity = false;
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
    _isBooking = true;
    _error = null;
    notifyListeners();

    final result = await _deleteBookingUseCase.execute(
      userId: userId,
      eventId: event.id,
    );

    if (result.success) {
      _isReserved = false;
    } else {
      _error = result.errorMessage ?? "Failed to cancel booking. Please try again.";
    }

    _isBooking = false;
    notifyListeners();
  }
}

