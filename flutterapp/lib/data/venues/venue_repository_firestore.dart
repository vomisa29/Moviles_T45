import 'venue_firestore_ds.dart';
import 'venue_mapper.dart';
import '../../domain/venues/venue.dart';
import '../../domain/venues/venue_repository.dart';


class VenueRepositoryFirestore implements VenueRepository {
  final VenueFirestoreDs _dataSource;

  VenueRepositoryFirestore({VenueFirestoreDs? dataSource})
      : _dataSource = dataSource ?? VenueFirestoreDs.instance;

  @override
  Future<Venue?> getOne(String id) async {
    final dto = await _dataSource.getOne(id);
    if (dto == null) return null;
    return VenueMapper.toDomain(dto);
  }

  @override
  Future<List<Venue>> getAll() async {
    final dtos = await _dataSource.getAll();
    return VenueMapper.toDomainList(dtos);
  }

  @override
  Future<String> create(Venue venue) async {
    final dto = VenueMapper.fromDomain(venue);
    await _dataSource.create(dto);
    return dto.id;
  }

  @override
  Future<void> update(Venue venue) async {
    final dto = VenueMapper.fromDomain(venue);
    await _dataSource.update(dto);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }
}