import '../models/venue.dart';
import '../serviceAdapters/venue_firestore_adapter.dart';
import 'venue_repository_int.dart';


class VenueRepositoryImplementation implements VenueRepository {
  final VenueFirestoreDs _dataSource;

  VenueRepositoryImplementation({VenueFirestoreDs? dataSource})
      : _dataSource = dataSource ?? VenueFirestoreDs.instance;

  @override
  Future<Venue?> getOne(String id) {
    return _dataSource.getOne(id);
  }

  @override
  Future<List<Venue>> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<String> create(Venue venue) async {
    await _dataSource.create(venue);
    return venue.id;
  }

  @override
  Future<void> update(Venue venue) {
    return _dataSource.update(venue);
  }

  @override
  Future<void> delete(String id) {
    return _dataSource.delete(id);
  }
}
