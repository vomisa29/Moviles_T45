import 'package:flutterapp/model/models/cancelation.dart';
import 'package:flutterapp/model/serviceAdapters/analytics_adapters/cancelation_firestore_adapter.dart';
import 'cancelation_repository_int.dart';

class CancelationRepositoryImplementation implements CancelationRepository {
  final CancelationFirestoreDs _dataSource;

  CancelationRepositoryImplementation({CancelationFirestoreDs? dataSource})
      : _dataSource = dataSource ?? CancelationFirestoreDs.instance;

  @override
  Future<Cancelation?> getOne(String id) {
    return _dataSource.getOne(id);
  }

  @override
  Future<List<Cancelation>> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<Cancelation?> getOneByUseridAndEventid({
    required String userId,
    required String eventId,
  }) {
    return _dataSource.getOneByUseridAndEventid(userId: userId, eventId: eventId);
  }

  @override
  Future<void> deleteByUseridAndEventid({
    required String userId,
    required String eventId,
  }) {
    return _dataSource.deleteByUseridAndEventid(userId: userId, eventId: eventId);
  }

  @override
  Future<String> create(Cancelation cancelation) {
    return _dataSource.create(cancelation);
  }
}
