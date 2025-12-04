class Cancelation {
  final String id;
  final String userId;
  final String venueId;
  final String eventId;
  final DateTime timestamp;

  const Cancelation({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.eventId,
    required this.timestamp,
  });
}
