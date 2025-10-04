import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_dto.dart';

class EventFirestoreDs {
  EventFirestoreDs._();
  static final EventFirestoreDs instance = EventFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('events');

  String generateId() => _col.doc().id;

  Future<EventDto?> getOne(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return EventDto.fromFirestore(snap);
  }

  Future<List<EventDto>> getAll() async {
    final q = await _col.get();
    return q.docs
        .map((d) => EventDto.fromFirestore(d))
        .toList(growable: false);
  }

  Future<void> create(EventDto dto) async {
    await _col.doc(dto.id).set(dto.toJson());
  }

  Future<void> update(EventDto dto) async {
    await _col.doc(dto.id).update(dto.toJson());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}

