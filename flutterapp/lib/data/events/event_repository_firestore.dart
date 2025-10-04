import 'event_firestore_ds.dart';
import 'event_mapper.dart';
import '../../domain/events/event.dart';
import '../../domain/events/event_repository.dart';

class EventRepositoryFirestore implements EventRepository {
  final EventFirestoreDs _dataSource;

  EventRepositoryFirestore({EventFirestoreDs? dataSource})
      : _dataSource = dataSource ?? EventFirestoreDs.instance;

  @override
  Future<Event?> getOne(String id) async {
    final dto = await _dataSource.getOne(id);
    if (dto == null) return null;
    return EventMapper.toDomain(dto);
  }

  @override
  Future<List<Event>> getAll() async {
    final dtos = await _dataSource.getAll();
    return EventMapper.toDomainList(dtos);
  }

  @override
  Future<String> create(Event event) async {
    final dto = EventMapper.fromDomain(event);
    await _dataSource.create(dto);
    return dto.id;
  }

  @override
  Future<void> update(Event event) async {
    final dto = EventMapper.fromDomain(event);
    await _dataSource.update(dto);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}
