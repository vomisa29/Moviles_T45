import '../models/venue.dart';

abstract class VenueRepository {

  Future<List<Venue>> getAll();

  Future<Venue?> getOne(String id);

  Future<String> create(Venue venue);

  Future<void> update(Venue venue);

  Future<void> delete(String id);
}