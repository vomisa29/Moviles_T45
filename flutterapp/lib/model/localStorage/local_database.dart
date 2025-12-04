import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

class AffinityScores extends Table {

  TextColumn get eventId => text()();
  RealColumn get score => real()();
  DateTimeColumn get lastCalculated => dateTime()();

  @override
  Set<Column> get primaryKey => {eventId};
}

@DriftDatabase(tables: [AffinityScores])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'affinity_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
