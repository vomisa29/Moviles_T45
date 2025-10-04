class Venue {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int capacity;
  final int bookingCount;

  const Venue({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.bookingCount,
  });
}
