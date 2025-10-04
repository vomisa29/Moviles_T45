import 'package:cloud_firestore/cloud_firestore.dart';

class EventDto {
  final String id;
  final String name;
  final String description;
  final String sport;
  final Timestamp startTime;
  final Timestamp endTime;
  final int maxCapacity;
  final String skillLevel;
  final double assistanceRate;
  final int booked;
  final int assisted;
  final double avgRating;
  final int numRatings;
  final String venueId;
  final String organizerId;

  EventDto({
    required this.id,
    required this.name,
    required this.description,
    required this.sport,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.skillLevel,
    required this.assistanceRate,
    required this.booked,
    required this.assisted,
    required this.avgRating,
    required this.numRatings,
    required this.venueId,
    required this.organizerId,
  });

  factory EventDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EventDto(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String,
      sport: data['sport'] as String,
      startTime: data['start_time'] as Timestamp,
      endTime: data['end_time'] as Timestamp,
      maxCapacity: (data['max_capacity'] as num).toInt(),
      skillLevel: data['skill_level'] as String,
      assistanceRate: (data['assistance_rate'] as num).toDouble(),
      booked: (data['booked'] as num).toInt(),
      assisted: (data['assisted'] as num).toInt(),
      avgRating: (data['avg_rating'] as num).toDouble(),
      numRatings: (data['num_ratings'] as num).toInt(),
      venueId: data['venueid'] as String,
      organizerId: data['organizerid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'sport': sport,
      'start_time': startTime,
      'end_time': endTime,
      'max_capacity': maxCapacity,
      'skill_level': skillLevel,
      'assistance_rate': assistanceRate,
      'booked': booked,
      'assisted': assisted,
      'avg_rating': avgRating,
      'num_ratings': numRatings,
      'venueid': venueId,
      'organizerid': organizerId,
    };
  }
}
