import '../../model/models/booked.dart';
import '../../model/repositories/booked_repository_imp.dart';
import '../../model/repositories/user_repository_imp.dart';
import '../../model/repositories/event_repository_imp.dart';
import 'useCase_result.dart';

class CreateBookingUseCase {
  final BookedEventRepositoryImplementation _bookedEventRepository;
  final UserRepositoryImplementation _userRepository;
  final EventRepositoryImplementation _eventRepository;


  CreateBookingUseCase({
    required BookedEventRepositoryImplementation bookedEventRepository,
    required UserRepositoryImplementation userRepository,
    required EventRepositoryImplementation eventRepository,
  })  : _bookedEventRepository = bookedEventRepository,
        _userRepository = userRepository,
        _eventRepository = eventRepository;

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
      final checks = await Future.wait([
        _userRepository.getOne(userId),
        _eventRepository.getOne(eventId),
      ]);

      final userExists = checks[0] != null;
      final eventExists = checks[1] != null;

      if (!userExists) {
        return const UseCaseResult(success: false, errorMessage: "User not found.");
      }
      if (!eventExists) {
        return const UseCaseResult(success: false, errorMessage: "Event not found.");
      }

      final isAlreadyBooked = await _bookedEventRepository.isEventBookedByUser(
        userId: userId,
        eventId: eventId,
      );

      if (isAlreadyBooked) {
        return const UseCaseResult(success: false, errorMessage: "You have already reserved this event.");
      }


      final newBooking = BookedEvent(
        eventId: eventId,
        userId: userId,
      );

      await _bookedEventRepository.create(newBooking);

      return const UseCaseResult(success: true);

    } catch (e) {
      return UseCaseResult(success: false, errorMessage: "An unexpected error occurred: $e");
    }
  }
}
