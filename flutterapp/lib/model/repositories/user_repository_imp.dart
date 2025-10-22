import '../models/user.dart';
import '../serviceAdapters/user_firestore_adapter.dart';
import 'user_repository_int.dart';


class UserRepositoryImplementation implements UserRepository {
  final UserFirestoreDs _dataSource;

  UserRepositoryImplementation({UserFirestoreDs? dataSource})
      : _dataSource = dataSource ?? UserFirestoreDs.instance;

  @override
  Future<User?> getOne(String id) {
    return _dataSource.getOne(id);
  }

  @override
  Future<List<User>> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<String> create(User user) async {
    await _dataSource.create(user);
    return user.uid;
  }

  @override
  Future<void> update(User user) {
    return _dataSource.update(user);
  }

  @override
  Future<void> delete(String id) {
    return _dataSource.delete(id);
  }
}
