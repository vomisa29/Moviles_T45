import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/events/event.dart';
import 'event_dto.dart';


class EventMapper {

  static Event toDomain(EventDto dto) {
    return Event(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      sport: sportFromString(dto.sport),
      startTime: dto.startTime.toDate(),
      endTime: dto.endTime.toDate(),
      maxCapacity: dto.maxCapacity,
      skillLevel: skillFromString(dto.skillLevel),
      assistanceRate: dto.assistanceRate,
      booked: dto.booked,
      assisted: dto.assisted,
      avgRating: dto.avgRating,
      numRatings: dto.numRatings,
      venueId: dto.venueId.id,
      organizerId: dto.organizerId.id,
    );
  }

  static EventDto fromDomain(Event event, FirebaseFirestore db) {
    return EventDto(
      id: event.id,
      name: event.name,
      description: event.description,
      sport: sportToString(event.sport),
      startTime: Timestamp.fromDate(event.startTime),
      endTime: Timestamp.fromDate(event.endTime),
      maxCapacity: event.maxCapacity,
      skillLevel: skillToString(event.skillLevel),
      assistanceRate: event.assistanceRate,
      booked: event.booked,
      assisted: event.assisted,
      avgRating: event.avgRating,
      numRatings: event.numRatings,
      venueId: db.collection('venues').doc(event.venueId),
      organizerId: db.collection('users').doc(event.organizerId)
    );
  }

  static List<Event> toDomainList(List<EventDto> dtos) =>
      dtos.map(toDomain).toList(growable: false);

  static List<EventDto> fromDomainList(
      List<Event> events,
      FirebaseFirestore db,
      ) =>
      events.map((e) => fromDomain(e, db)).toList(growable: false);
}