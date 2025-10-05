import 'event_firestore_ds.dart';
import 'event_mapper.dart';
import '../../domain/events/event.dart';
import '../../domain/events/event_repository.dart';
import '../venues/venue_repository_firestore.dart';
import 'dart:math';
import '../../domain/venues/venue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventRepositoryFirestore implements EventRepository {
  final EventFirestoreDs _dataSource;
  final VenueRepositoryFirestore _venueRepository;

  EventRepositoryFirestore({
    EventFirestoreDs? dataSource,
    VenueRepositoryFirestore? venueRepository,
  })  : _dataSource = dataSource ?? EventFirestoreDs.instance,
        _venueRepository =
            venueRepository ?? VenueRepositoryFirestore();

  @override
  Future<Event?> getOne(String id) async {
    final dto = await _dataSource.getOne(id);
    if (dto == null) return null;

    final event = EventMapper.toDomain(dto);
    final venue = await _venueRepository.getOne(event.venueId);
    if (venue != null) {
      return event.copyWith(
        latitude: venue.latitude,
        longitude: venue.longitude,
      );
    }
    return event;
  }

  @override
  Future<List<Event>> getAll() async {
    final dtos = await _dataSource.getAll();
    final events = EventMapper.toDomainList(dtos);

    final enriched = <Event>[];
    for (final event in events) {
      final venue = await _venueRepository.getOne(event.venueId);
      if (venue != null) {
        enriched.add(event.copyWith(
          latitude: venue.latitude,
          longitude: venue.longitude,
        ));
      } else {
        enriched.add(event);
      }
    }
    return enriched;
  }

  @override
  Future<String> create(Event event) async {
    final dto = EventMapper.fromDomain(event,FirebaseFirestore.instance);
    await _dataSource.create(dto);
    return dto.id;
  }

  @override
  Future<void> update(Event event) async {
    final dto = EventMapper.fromDomain(event,FirebaseFirestore.instance);
    await _dataSource.update(dto);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  @override
  Future<List<Event>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {

    final dtos = await _dataSource.getAll();
    final events = dtos.map(EventMapper.toDomain).toList(growable: false);

    final nearbyEvents = <Event>[];
    final venueDict = <String, Venue?>{};

    for (final event in events) {

      final venue = venueDict[event.venueId] ??
          await _venueRepository.getOne(event.venueId);

      venueDict[event.venueId] = venue;

      if (venue != null) {
        final vLat = venue.latitude;
        final vLng = venue.longitude;
        final distance = _distanceKm(latitude, longitude, vLat, vLng);
        if (distance <= radiusKm) {
            nearbyEvents.add(event.copyWith(
              latitude: vLat,
              longitude: vLng,
            ));
          }

      }
    }

    return nearbyEvents;
  }

  //Otras funciones chiquitas para el calculo de distancia
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
                sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) { return deg * (pi / 180.0);}
}
