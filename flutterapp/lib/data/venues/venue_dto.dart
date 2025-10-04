import 'package:cloud_firestore/cloud_firestore.dart';

class VenueDto {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int capacity;
  final int bookingCount;

  VenueDto({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.bookingCount,
  });

  factory VenueDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VenueDto(
      id: doc.id,
      name: data['name'] as String,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      capacity: (data['capacity'] as num).toInt(),
      bookingCount: (data['booking_count'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'booking_count': bookingCount,
    };
  }
}
