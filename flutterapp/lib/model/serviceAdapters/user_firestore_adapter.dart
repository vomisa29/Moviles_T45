import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserFirestoreDs {
  UserFirestoreDs._();
  static final UserFirestoreDs instance = UserFirestoreDs._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users');

  Future<User?> getOne(String uid) async {
    final snap = await _col.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return _fromFirestore(snap);
  }

  Future<List<User>> getAll() async {
    final q = await _col.get();
    return q.docs.map((d) => _fromFirestore(d)).toList(growable: false);
  }

  Future<void> create(User user) async {
    await _col.doc(user.uid).set(_toJson(user));
  }

  Future<void> update(User user) async {
    await _col.doc(user.uid).update(_toJson(user));
  }

  Future<void> delete(String uid) async {
    await _col.doc(uid).delete();
  }

  User _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return User(
      uid: doc.id,
      username: data['username'],
      email: data['email'],
      description: data['description'],
      role: roleFromString(data['role']),
      createdAt: data['createdAt'],
      sportList: List<String>.from(data['sportList'] ?? []),
      avgRating: (data['avgRating']).toDouble(),
      numRating: data['numRating'],
      assistanceRate: (data['assistanceRate']).toDouble(),
    );
  }

  Map<String, dynamic> _toJson(User user) {
    return {
      'username': user.username,
      'email': user.email,
      'description': user.description,
      'role': roleToString(user.role),
      'createdAt': Timestamp.fromDate(user.createdAt),
      'sportList': user.sportList,
      'avgRating': user.avgRating,
      'numRating': user.numRating,
      'assistanceRate': user.assistanceRate,
    };
  }
}
