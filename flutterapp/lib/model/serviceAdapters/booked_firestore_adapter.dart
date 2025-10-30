import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booked.dart';

class BookedFirestoreDs {
  BookedFirestoreDs._();
  static final BookedFirestoreDs instance = BookedFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('booked');

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      FirebaseFirestore.instance.collection('users');

  CollectionReference<Map<String, dynamic>> get _eventsCol =>
      FirebaseFirestore.instance.collection('events');

  Future<BookedEvent?> getOne(String docId) async {
    final snap = await _col.doc(docId).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap);
  }

  Future<List<BookedEvent>> getBookingsForUser(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final querySnapshot = await _col.where('userid', isEqualTo: userRef).get();
    return querySnapshot.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<List<BookedEvent>> getBookingsForEvent(String eventId) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    final querySnapshot = await _col.where('eventid', isEqualTo: eventRef).get();
    return querySnapshot.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<String> create(BookedEvent booking) async {
    final docRef = _col.doc();
    await docRef.set(_toJson(booking));
    return docRef.id;
  }

  Future<void> delete(String docId) async {
    await _col.doc(docId).delete();
  }

  BookedEvent _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final DocumentReference eventRef = data['eventid'];
    final DocumentReference userRef = data['userid'];

    return BookedEvent(
      eventId: eventRef.id,
      userId: userRef.id,
    );
  }

  Map<String, dynamic> _toJson(BookedEvent booking) {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(booking.eventId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(booking.userId);

    return {
      'eventid': eventRef,
      'userid': userRef,
    };
  }
  
  Future<bool> isEventBookedByUser({required String userId, required String eventId}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);

    final querySnapshot = await _col
        .where('userid', isEqualTo: userRef)
        .where('eventid', isEqualTo: eventRef)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> cancelByUserIdAndEventId({required String userId, required String eventId}) async {
    final userRef = _usersCol.doc(userId);
    final eventRef = _eventsCol.doc(eventId);

    final querySnapshot = await _col
        .where('userid', isEqualTo: userRef)
        .where('eventid', isEqualTo: eventRef)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await _col.doc(docId).delete();
    } else {
      throw Exception("No booking found for the given user and event.");
    }
  }


}
