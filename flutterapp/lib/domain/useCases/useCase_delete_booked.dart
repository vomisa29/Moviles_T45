import 'package:flutterapp/model/models/cancelation.dart';
import 'package:flutterapp/model/repositories/analytics_repositories/cancelation_repository_imp.dart';
import 'package:flutterapp/model/repositories/booked_repository_imp.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'useCase_result.dart';

class DeleteBookingUseCase {
  final BookedEventRepositoryImplementation _bookedEventRepository;
  final EventRepositoryImplementation _eventRepository;
  final CancelationRepositoryImplementation _cancelationRepository;

  DeleteBookingUseCase({
    required BookedEventRepositoryImplementation bookedEventRepository,
    required EventRepositoryImplementation eventRepository,
    required CancelationRepositoryImplementation cancelationRepository,
  })  : _bookedEventRepository = bookedEventRepository,
        _eventRepository = eventRepository,
        _cancelationRepository = cancelationRepository;

  Future<UseCaseResult> execute({
    required String? userId,
    required String? eventId,
  }) async {
    if (userId == null || userId.isEmpty) {
      return const UseCaseResult(success: false, errorMessage: "User is not logged in.");
    }
    if (eventId == null || eventId.isEmpty) {
      return const UseCaseResult(success: false, errorMessage: "Invalid event specified.");
    }

    try {
      final isBooked = await _bookedEventRepository.isEventBookedByUser(
        userId: userId,
        eventId: eventId,
      );

      if (!isBooked) {
        return const UseCaseResult(success: false, errorMessage: "You are not booked for this event.");
      }

      final event = await _eventRepository.getOne(eventId);
      if (event == null) {
        return const UseCaseResult(success: false, errorMessage: "Cannot find the event details to process cancellation.");
      }

      final newCancelation = Cancelation(
        id: '',
        userId: userId,
        venueId: event.venueId,
        eventId: event.id,
        timestamp: DateTime.now(),
      );

      await Future.wait([
        _bookedEventRepository.cancelByUserIdAndEventId(userId: userId, eventId: eventId),
        _cancelationRepository.create(newCancelation),
      ]);

      print("Booking deleted and cancellation created for user $userId at event $eventId");

      return const UseCaseResult(success: true);

    } catch (e) {
      return UseCaseResult(success: false, errorMessage: "An unexpected error occurred during cancellation: $e");
    }
  }
}
