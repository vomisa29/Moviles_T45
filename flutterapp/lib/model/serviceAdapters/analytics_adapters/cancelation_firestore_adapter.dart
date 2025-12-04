import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterapp/model/models/cancelation.dart';

class CancelationFirestoreDs {

  CancelationFirestoreDs._();
  static final CancelationFirestoreDs instance = CancelationFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('cancelations');

  Future<Cancelation?> getOne(String id) async {
    final snap = await _col.doc(id).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap);
  }

  Future<List<Cancelation>> getAll() async {
    final q = await _col.get();
    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<Cancelation?> getOneByUseridAndEventid({
    required String userId,
    required String eventId,
  }) async {
    final query = await _col
        .where('userid', isEqualTo: userId)
        .where('eventid', isEqualTo: eventId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }
    return _fromFirestore(query.docs.first);
  }

  Future<void> deleteByUseridAndEventid({
    required String userId,
    required String eventId,
  }) async {
    final query = await _col
        .where('userid', isEqualTo: userId)
        .where('eventid', isEqualTo: eventId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await _col.doc(query.docs.first.id).delete();
    }
  }

  Future<String> create(Cancelation cancelation) async {
    final docRef = await _col.add(_toJson(cancelation));
    return docRef.id;
  }

  Cancelation _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Cancelation(
      id: doc.id,
      userId: data['userid'],
      venueId: data['venueid'],
      eventId: data['eventid'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> _toJson(Cancelation cancelation) {
    return {
      'userid': cancelation.userId,
      'venueid': cancelation.venueId,
      'eventid': cancelation.eventId,
      'timestamp': Timestamp.fromDate(cancelation.timestamp),
    };
  }
}
