import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventFirestoreDs {
  EventFirestoreDs._();
  static final EventFirestoreDs instance = EventFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('events');

  String generateId() => _col.doc().id;

  Future<Event?> getOne(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap);
  }

  Future<List<Event>> getAll() async {
    final q = await _col.get();
    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<void> create(Event event) async {
    await _col.doc(event.id).set(_toJson(event));
  }

  Future<void> update(Event event) async {
    await _col.doc(event.id).update(_toJson(event));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  //mapeo
  Event _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final DocumentReference venueRef = data['venueid'];
    final DocumentReference organizerRef = data['organizerid'];

    return Event(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      sport: sportFromString(data['sport']),
      startTime: (data['start_time'] as Timestamp).toDate(),
      endTime: (data['end_time'] as Timestamp).toDate(),
      maxCapacity: data['max_capacity'],
      skillLevel: skillFromString(data['skill_level']),
      assistanceRate: (data['assistance_rate']).toDouble(),
      booked: data['booked'],
      assisted: data['assisted'],
      avgRating: (data['avg_rating']).toDouble(),
      numRatings: data['num_ratings'],
      venueId: venueRef.id,
      organizerId: organizerRef.id,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _toJson(Event event) {
    final venueRef = FirebaseFirestore.instance.collection('venues').doc(event.venueId);
    final organizerRef = FirebaseFirestore.instance.collection('users').doc(event.organizerId);

    return {
      'name': event.name,
      'description': event.description,
      'sport': sportToString(event.sport),
      'start_time': Timestamp.fromDate(event.startTime),
      'end_time': Timestamp.fromDate(event.endTime),
      'max_capacity': event.maxCapacity,
      'skill_level': skillToString(event.skillLevel),
      'assistance_rate': event.assistanceRate,
      'booked': event.booked,
      'assisted': event.assisted,
      'avg_rating': event.avgRating,
      'num_ratings': event.numRatings,
      'venueid': venueRef,
      'organizerid': organizerRef,
      'latitude': event.latitude,
      'longitude': event.longitude,
    };
  }
}
