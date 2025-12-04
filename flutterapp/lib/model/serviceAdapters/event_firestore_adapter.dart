import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventFirestoreDs {
  EventFirestoreDs._();
  static final EventFirestoreDs instance = EventFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('events');

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      FirebaseFirestore.instance.collection('users');

  CollectionReference<Map<String, dynamic>> get _venuesCol =>
      FirebaseFirestore.instance.collection('venues');

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

  Future<List<Event>> getByOrganizer(String organizerid) async {
    final organizerRef = _usersCol.doc(organizerid);
    final q = await _col.where('organizerid', isEqualTo: organizerRef).get();

    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<List<Event>> getByVenue(String venueid) async {
    final venueRef = _venuesCol.doc(venueid);
    final q = await _col.where('venueid', isEqualTo: venueRef).get();

    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<List<Event>> getByName(String eventName) async {
    final q = await _col.where('name', isEqualTo: eventName).get();
    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<List<Event>> getOverlappingEvents(
      {required String venueId,
        required DateTime startTime,
        required DateTime endTime}) async {

    final venueRef = FirebaseFirestore.instance.collection('venues').doc(venueId);

    final query = await _col
        .where('venueid', isEqualTo: venueRef)
        .where('start_time', isLessThan: endTime)
        .get();

    return query.docs
        .map((d) => _fromFirestore(d))
        .where((event) => event.endTime.isAfter(startTime))
        .toList();
  }

  Future<String> create(Event event) async {
    final docRef = _col.doc();
    await docRef.set(toJson(event));
    return docRef.id;
  }

  Future<void> update(Event event) async {
    await _col.doc(event.id).update(toJson(event));
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
      assistanceRate: (data['assistance_rate'] as num?)?.toDouble(),
      booked: data['booked'],
      assisted: (data['assisted'] as num?)?.toInt(),
      avgRating: (data['avg_rating'] as num?)?.toDouble(),
      numRatings: (data['num_ratings'] as num?)?.toInt(),
      venueId: venueRef.id,
      organizerId: organizerRef.id,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson(Event event) {
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

  Event fromJson(Map<String, dynamic> json) {
    return Event(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      sport: json["sport"],
      startTime: DateTime.parse(json["startTime"]),
      endTime: DateTime.parse(json["endTime"]),
      maxCapacity: json["maxCapacity"],
      skillLevel: json["skillLevel"],
      assistanceRate: json["assistanceRate"],
      booked: json["booked"],
      assisted: json["assisted"],
      avgRating: json["avgRating"],
      numRatings: json["numRatings"],
      venueId: json["venueId"],
      organizerId: json["organizerId"],
      latitude: json["latitude"],
      longitude: json["longitude"]
    );
  }
}
