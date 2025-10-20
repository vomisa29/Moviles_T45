import '../models/user.dart';

abstract class VenueRepository {

  Future<List<User>> getAll();

  Future<User?> getOne(String id);

  Future<String> create(User user);

  Future<void> update(User user);

  Future<void> delete(String id);
}