import '../models/booked.dart';
import '../serviceAdapters/booked_firestore_adapter.dart';
import 'booked_repository_int.dart';

class BookedEventRepositoryImplementation implements BookedEventRepository {
  final BookedFirestoreDs _dataSource;

  BookedEventRepositoryImplementation({BookedFirestoreDs? dataSource})
      : _dataSource = dataSource ?? BookedFirestoreDs.instance;

  @override
  Future<BookedEvent?> getOne(String docId) {
    return _dataSource.getOne(docId);
  }

  @override
  Future<List<BookedEvent>> getBookingsForUser(String userId) {
    return _dataSource.getBookingsForUser(userId);
  }

  @override
  Future<List<BookedEvent>> getBookingsForEvent(String eventId) {
    return _dataSource.getBookingsForEvent(eventId);
  }

  @override
  Future<String> create(BookedEvent booking) {
    return _dataSource.create(booking);
  }

  @override
  Future<void> delete(String docId) {
    return _dataSource.delete(docId);
  }

  @override
  Future<bool> isEventBookedByUser({required String userId, required String eventId}) {
    return _dataSource.isEventBookedByUser(userId: userId, eventId: eventId);
  }

  @override
  Future<void> cancelByUserIdAndEventId({required String userId, required String eventId}) {
    return _dataSource.cancelByUserIdAndEventId(userId: userId, eventId: eventId);
  }
}