import 'event.dart';

abstract class EventRepository {

  Future<List<Event>> getAll();

  Future<Event?> getOne(String id);

  Future<String> create(Event event);

  Future<void> update(Event event);

  Future<void> delete(String id);
}