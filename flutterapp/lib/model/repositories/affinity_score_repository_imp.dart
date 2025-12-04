import 'package:flutterapp/model/localStorage/local_database.dart';
import 'package:drift/drift.dart';
import 'affinity_score_repository_int.dart';

class AffinityScoreRepositoryImp implements AffinityScoreRepository {
  static final LocalDatabase _database = LocalDatabase();

  @override
  Future<AffinityScore?> getAffinityScore(String eventId) async {
    return (_database.select(_database.affinityScores)
      ..where((tbl) => tbl.eventId.equals(eventId)))
        .getSingleOrNull();
  }

  @override
  Future<void> saveAffinityScore(AffinityScoresCompanion scoreCompanion) async {

    await _database.into(_database.affinityScores).insert(
      scoreCompanion,
      mode: InsertMode.replace,
    );
  }

  @override
  Future<void> deleteAffinityScore(String eventId) async {
    await (_database.delete(_database.affinityScores)
      ..where((tbl) => tbl.eventId.equals(eventId)))
        .go();
  }
}
