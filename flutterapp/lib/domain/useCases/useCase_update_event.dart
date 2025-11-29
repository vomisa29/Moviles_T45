import '../../model/models/event.dart';
import '../../model/repositories/event_repository_imp.dart';
import 'useCase_result.dart';

class UpdateEventUseCase {
  final EventRepositoryImplementation _eventRepository;
  UpdateEventUseCase({
    required EventRepositoryImplementation eventRepository,
  }) : _eventRepository = eventRepository;

  Future<UseCaseResult> execute(Event updatedEvent) async {
    try {
      final existingEvent = await _eventRepository.getOne(updatedEvent.id);
      if (existingEvent == null) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The event you are trying to update does not exist.",
        );
      }
      if (existingEvent.venueId != updatedEvent.venueId) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The event's venue cannot be changed.",
        );
      }

      if (existingEvent.startTime != updatedEvent.startTime || existingEvent.endTime != updatedEvent.endTime) {
        return const UseCaseResult(
          success: false,
          errorMessage: "The event's date and time cannot be changed.",
        );
      }

      if (updatedEvent.maxCapacity < existingEvent.booked) {
        return UseCaseResult(
          success: false,
          errorMessage:
          "Event capacity (${updatedEvent.maxCapacity}) cannot be less than the number of currently booked users (${existingEvent.booked}).",
        );
      }

      await _eventRepository.update(updatedEvent);

      return const UseCaseResult(success: true);
    } catch (e) {
      return UseCaseResult(
        success: false,
        errorMessage: "An unexpected error occurred during the update: ${e.toString()}",
      );
    }
  }
}
