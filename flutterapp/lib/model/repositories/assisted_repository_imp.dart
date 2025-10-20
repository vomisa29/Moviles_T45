import '../models/assisted.dart';
import '../serviceAdapters/assisted_firestore_adapter.dart';
import 'assisted_repository_int.dart';

class AssistedEventRepositoryFirestore implements AssistedEventRepository {
  final AssistedFirestoreDs _dataSource;

  AssistedEventRepositoryFirestore({AssistedFirestoreDs? dataSource})
      : _dataSource = dataSource ?? AssistedFirestoreDs.instance;

  @override
  Future<AssistedEvent?> getOne(String docId) {
    return _dataSource.getOne(docId);
  }

  @override
  Future<List<AssistedEvent>> getBookingsForUser(String userId) {
    return _dataSource.getBookingsForUser(userId);
  }

  @override
  Future<List<AssistedEvent>> getBookingsForEvent(String eventId) {
    return _dataSource.getBookingsForEvent(eventId);
  }

  @override
  Future<String> create(AssistedEvent booking) {
    return _dataSource.create(booking);
  }

  @override
  Future<void> delete(String docId) {
    return _dataSource.delete(docId);
  }
}
