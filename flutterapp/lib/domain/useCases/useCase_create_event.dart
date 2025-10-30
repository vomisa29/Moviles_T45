import '../../model/models/event.dart';
import '../../model/repositories/user_repository_imp.dart';
import '../../model/repositories/venue_repository_imp.dart';
import '../../model/repositories/event_repository_imp.dart';
import 'useCase_result.dart';

class CreateEventUseCase {
  final UserRepositoryImplementation _userRepository;
  final VenueRepositoryImplementation _venueRepository;
  final EventRepositoryImplementation _eventRepository;

  CreateEventUseCase({
    required UserRepositoryImplementation userRepository,
    required EventRepositoryImplementation eventRepository,
    required VenueRepositoryImplementation venueRepository,
  })  : _userRepository = userRepository,
        _venueRepository = venueRepository,
        _eventRepository = eventRepository;

  Future<UseCaseResult> execute(Event event) async {
    try {
      final organizer = await _userRepository.getOne(event.organizerId);
      if (organizer == null) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The organizer specified is not a valid user.",
        );
      }

      final venue = await _venueRepository.getOne(event.venueId);
      if (venue == null) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The selected venue does not exist.",
        );
      }

      if (event.maxCapacity > venue.capacity) {
        return UseCaseResult(
          success: false,
          errorMessage:
          "Event capacity (${event.maxCapacity}) cannot be greater than venue capacity (${venue.capacity}).",
        );
      }

      if (event.startTime.isBefore(DateTime.now())) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The event start time must be in the future.",
        );
      }

      if (event.endTime.isBefore(event.startTime) ||
          event.endTime.isAtSameMomentAs(event.startTime)) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The event end time must be after the start time.",
        );
      }

      final overlappingEvents = await _eventRepository.getOverlappingEvents(
        venueId: event.venueId,
        startTime: event.startTime,
        endTime: event.endTime,
      );

      if (overlappingEvents.isNotEmpty) {
        return const UseCaseResult(
          success: false,
          errorMessage: "This time slot is already booked for the selected venue.",
        );
      }

      await _eventRepository.create(event);

      return const UseCaseResult(success: true);
    } catch (e) {
      return UseCaseResult(
        success: false,
        errorMessage: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }
}
