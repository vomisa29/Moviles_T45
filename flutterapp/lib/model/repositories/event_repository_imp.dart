import 'dart:math';
import '../models/event.dart';
import '../models/venue.dart';
import '../serviceAdapters/event_firestore_adapter.dart';
import 'event_repository_int.dart';
import 'venue_repository_imp.dart';

class EventRepositoryImplementation implements EventRepository {
  final EventFirestoreDs _dataSource;
  final VenueRepositoryImplementation _venueRepository;

  EventRepositoryImplementation({
    EventFirestoreDs? dataSource,
    VenueRepositoryImplementation? venueRepository,
  })  : _dataSource = dataSource ?? EventFirestoreDs.instance,
        _venueRepository = venueRepository ?? VenueRepositoryImplementation();

  @override
  Future<Event?> getOne(String id) async {
    final event = await _dataSource.getOne(id);
    if (event == null) return null;

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
    final events = await _dataSource.getAll();
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
    await _dataSource.create(event);
    return event.id;
  }

  @override
  Future<void> update(Event event) async {
    await _dataSource.update(event);
  }

  @override
  Future<void> delete(String id) async {
    await _dataSource.delete(id);
  }

  /*@override
  Future<List<Event>> getNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    final events = await _dataSource.getAll();

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
  }*/

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180.0);
  }
}
