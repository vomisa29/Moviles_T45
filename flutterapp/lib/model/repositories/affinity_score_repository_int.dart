import '../localStorage/local_database.dart';

abstract class AffinityScoreRepository {

  Future<AffinityScore?> getAffinityScore(String eventId);

  Future<void> saveAffinityScore(AffinityScoresCompanion scoreCompanion);

  Future<void> deleteAffinityScore(String eventId);
}
