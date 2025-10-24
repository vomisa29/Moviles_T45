import '../models/assisted.dart';


abstract class AssistedEventRepository {

  Future<AssistedEvent?> getOne(String docId);

  Future<List<AssistedEvent>> getBookingsForUser(String userId);

  Future<List<AssistedEvent>> getBookingsForEvent(String eventId);

  Future<String> create(AssistedEvent booking);
  
  Future<void> delete(String docId);

}
