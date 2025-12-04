import 'dart:isolate';
import 'package:flutterapp/model/localStorage/local_database.dart';
import 'package:flutterapp/model/models/event.dart';
import 'package:flutterapp/model/models/user.dart';
import 'package:flutterapp/model/repositories/affinity_score_repository_imp.dart';
import 'package:flutterapp/model/repositories/booked_repository_imp.dart';
import 'package:flutterapp/model/repositories/event_repository_imp.dart';
import 'package:flutterapp/model/repositories/user_repository_imp.dart';
import 'useCase_result.dart';

//Esto es lo del isolate
class _AffinityPayload {
  final SendPort sendPort;
  final User currentUser;
  final Event targetEvent;
  final List<Event> userAttendanceHistory;

  _AffinityPayload({
    required this.sendPort,
    required this.currentUser,
    required this.targetEvent,
    required this.userAttendanceHistory,
  });
}

void _calculateAffinityInIsolate(_AffinityPayload payload) {
  double score = 0.0;
  if (payload.currentUser.sportList?.map((s) => s.toLowerCase()).contains(sportToString(payload.targetEvent.sport).toLowerCase()) ?? false) {
    score += 0.40;
  }
  final userSkillIndex = payload.currentUser.avgRating?.round() ?? 3;
  final eventSkillIndex = payload.targetEvent.skillLevel.index;
  final skillDifference = (userSkillIndex - eventSkillIndex).abs();
  if (skillDifference == 0) {
    score += 0.25;
  } else if (skillDifference == 1) {
    score += 0.15;
  }
  if (payload.userAttendanceHistory.any((event) => event.venueId == payload.targetEvent.venueId)) {
    score += 0.15;
  }
  score += ((payload.currentUser.avgRating ?? 2.5) / 5.0) * 0.20;
  payload.sendPort.send(score.clamp(0.0, 1.0));
}
//Hasta aca

class GetAffinityUseCase {
  final UserRepositoryImplementation _userRepository;
  final EventRepositoryImplementation _eventRepository;
  final BookedEventRepositoryImplementation _bookedRepository;
  final AffinityScoreRepositoryImp _affinityRepository;

  GetAffinityUseCase({
    required UserRepositoryImplementation userRepository,
    required EventRepositoryImplementation eventRepository,
    required BookedEventRepositoryImplementation bookedRepository,
    required AffinityScoreRepositoryImp affinityRepository,
  })  : _userRepository = userRepository,
        _eventRepository = eventRepository,
        _bookedRepository = bookedRepository,
        _affinityRepository = affinityRepository;

  Future<UseCaseResult> execute({
    required String userId,
    required Event targetEvent,
  }) async {
    try {

      final cachedScore = await _affinityRepository.getAffinityScore(targetEvent.id);
      if (cachedScore != null && DateTime.now().difference(cachedScore.lastCalculated).inDays < 3) {
        return UseCaseResult(success: true, data: cachedScore.score);
      }

      final currentUser = await _userRepository.getOne(userId);
      if (currentUser == null) {
        return const UseCaseResult(success: false, errorMessage: "Current user data could not be found.");
      }

      final bookings = await _bookedRepository.getBookingsForUser(userId);
      final attendedEventIds = bookings.map((b) => b.eventId).toList();

      final List<Event> attendanceHistory = [];
      for (var id in attendedEventIds) {
        final ev = await _eventRepository.getOne(id);
        if (ev != null) {
          attendanceHistory.add(ev);
        }
      }

      final receivePort = ReceivePort();
      final payload = _AffinityPayload(
        sendPort: receivePort.sendPort,
        currentUser: currentUser,
        targetEvent: targetEvent,
        userAttendanceHistory: attendanceHistory,
      );

      await Isolate.spawn(_calculateAffinityInIsolate, payload);
      final score = await receivePort.first as double;

      await _affinityRepository.saveAffinityScore(
        AffinityScoresCompanion.insert(
          eventId: targetEvent.id,
          score: score,
          lastCalculated: DateTime.now(),
        ),
      );

      return UseCaseResult(success: true, data: score);

    } catch (e) {
      return UseCaseResult(
        success: false,
        errorMessage: "An unexpected error occurred while calculating affinity: ${e.toString()}",
      );
    }
  }
}
