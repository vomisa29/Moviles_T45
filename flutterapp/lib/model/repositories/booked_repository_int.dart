import '../models/booked.dart';


abstract class BookedEventRepository {

  Future<BookedEvent?> getOne(String docId);

  Future<List<BookedEvent>> getBookingsForUser(String userId);

  Future<List<BookedEvent>> getBookingsForEvent(String eventId);

  Future<String> create(BookedEvent booking);


  Future<void> delete(String docId);
}
