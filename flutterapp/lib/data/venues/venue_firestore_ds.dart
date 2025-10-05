import 'package:cloud_firestore/cloud_firestore.dart';
import 'venue_dto.dart';

class VenueFirestoreDs {
  VenueFirestoreDs._();
  static final VenueFirestoreDs instance = VenueFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('venues');

  String generateId() => _col.doc().id;

  Future<VenueDto?> getOne(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return VenueDto.fromFirestore(snap);
  }

  Future<List<VenueDto>> getAll() async {
    final q = await _col.get();
    return q.docs
        .map((d) => VenueDto.fromFirestore(d))
        .toList(growable: false);
  }

  Future<void> create(VenueDto dto) async {
    await _col.doc(dto.id).set(dto.toJson());
  }

  Future<void> update(VenueDto dto) async {
    await _col.doc(dto.id).update(dto.toJson());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}