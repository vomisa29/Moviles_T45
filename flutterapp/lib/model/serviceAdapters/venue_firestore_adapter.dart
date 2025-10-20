import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/venue.dart';

class VenueFirestoreDs {
  VenueFirestoreDs._();
  static final VenueFirestoreDs instance = VenueFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('venues');

  String generateId() => _col.doc().id;

  Future<Venue?> getOne(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap);
  }

  Future<List<Venue>> getAll() async {
    final q = await _col.get();
    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<void> create(Venue venue) async {
    await _col.doc(venue.id).set(_toJson(venue));
  }

  Future<void> update(Venue venue) async {
    await _col.doc(venue.id).update(_toJson(venue));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  //Metodos para mapear
  Venue _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Venue(
      id: doc.id,
      name: data['name'],
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      capacity: data['capacity'],
      bookingCount: data['booking_count'],
    );
  }

  Map<String, dynamic> _toJson(Venue venue) {
    return {
      'name': venue.name,
      'latitude': venue.latitude,
      'longitude': venue.longitude,
      'capacity': venue.capacity,
      'booking_count': venue.bookingCount,
    };
  }
}
