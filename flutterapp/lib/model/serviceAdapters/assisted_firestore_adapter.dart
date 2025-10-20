import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assisted.dart';

class AssistedFirestoreDs {
  AssistedFirestoreDs._();
  static final AssistedFirestoreDs instance = AssistedFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('Assisted');

  Future<AssistedEvent?> getOne(String docId) async {
    final snap = await _col.doc(docId).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap);
  }

  Future<List<AssistedEvent>> getBookingsForUser(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final querySnapshot = await _col.where('userid', isEqualTo: userRef).get();
    return querySnapshot.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<List<AssistedEvent>> getBookingsForEvent(String eventId) async {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(eventId);
    final querySnapshot = await _col.where('eventid', isEqualTo: eventRef).get();
    return querySnapshot.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<String> create(AssistedEvent booking) async {
    final docRef = _col.doc();
    await docRef.set(_toJson(booking));
    return docRef.id;
  }

  Future<void> delete(String docId) async {
    await _col.doc(docId).delete();
  }

  AssistedEvent _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final DocumentReference eventRef = data['eventid'];
    final DocumentReference userRef = data['userid'];

    return AssistedEvent(
      eventId: eventRef.id,
      userId: userRef.id,
    );
  }

  Map<String, dynamic> _toJson(AssistedEvent booking) {
    final eventRef = FirebaseFirestore.instance.collection('events').doc(booking.eventId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(booking.userId);

    return {
      'eventid': eventRef,
      'userid': userRef,
    };
  }
}
