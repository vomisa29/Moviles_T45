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

  Future<User?> getUserByUsername(String username) async {
    final query = await _col
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }
    return _fromFirestore(query.docs.first);
  }

  User _fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return User(
      uid: doc.id,
      email: data['email'],
      role: roleFromString(data['role']),

      username: data['username'] as String?,
      description: data['description'] as String?,

      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      sportList: data['sportList'] == null ? null : List<String>.from(data['sportList']),

      avgRating: (data['avgRating'] as num?)?.toDouble(),
      numRating: data['numRating'] as int?,
      assistanceRate: (data['assistanceRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> _toJson(User user) {
    return {
      'email': user.email,
      'role': roleToString(user.role),
      'uid': user.uid,

      if (user.username != null) 'username': user.username,
      if (user.description != null) 'description': user.description,
      if (user.createdAt != null) 'createdAt': Timestamp.fromDate(user.createdAt!),
      if (user.sportList != null) 'sportList': user.sportList,
      if (user.avgRating != null) 'avgRating': user.avgRating,
      if (user.numRating != null) 'numRating': user.numRating,
      if (user.assistanceRate != null) 'assistanceRate': user.assistanceRate,
    };
  }
}
