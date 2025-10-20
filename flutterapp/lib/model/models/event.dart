enum Sport { soccer, basketball, tennis, volleyball }
enum SkillLevel { rookie, amateur, midLevel, pro, any }

Sport sportFromString(String s) {
  switch (s.toLowerCase()) {
    case 'soccer': return Sport.soccer;
    case 'basketball': return Sport.basketball;
    case 'tennis': return Sport.tennis;
    case 'volleyball': return Sport.volleyball;
    default: throw ArgumentError('Unknown sport: $s');
  }
}

String sportToString(Sport s) {
  switch (s) {
    case Sport.soccer: return 'Soccer';
    case Sport.basketball: return 'Basketball';
    case Sport.tennis: return 'Tennis';
    case Sport.volleyball: return 'Volleyball';
  }
}

SkillLevel skillFromString(String s) {
  switch (s.toLowerCase()) {
    case 'rookie': return SkillLevel.rookie;
    case 'amateur': return SkillLevel.amateur;
    case 'mid-level': return SkillLevel.midLevel;
    case 'pro': return SkillLevel.pro;
    case 'any': return SkillLevel.any;
    default: throw ArgumentError('Unknown skill level: $s');
  }
}

String skillToString(SkillLevel s) {
  switch (s) {
    case SkillLevel.rookie: return 'Rookie';
    case SkillLevel.amateur: return 'Amateur';
    case SkillLevel.midLevel: return 'Mid-level';
    case SkillLevel.pro: return 'Pro';
    case SkillLevel.any: return 'Any';
  }
}

class Event {
  final String id;
  final String name;
  final String description;
  final Sport sport;
  final DateTime startTime;
  final DateTime endTime;
  final int maxCapacity;
  final SkillLevel skillLevel;
  final double assistanceRate;
  final int booked;
  final int assisted;
  final double avgRating;
  final int numRatings;
  final String venueId;
  final String organizerId;
  final double? latitude;
  final double? longitude;

  const Event({
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
    this.latitude,
    this.longitude,
  });

  Event copyWith({
    double? latitude,
    double? longitude,
  }) {
    return Event(
      id: id,
      name: name,
      description: description,
      sport: sport,
      startTime: startTime,
      endTime: endTime,
      maxCapacity: maxCapacity,
      skillLevel: skillLevel,
      assistanceRate: assistanceRate,
      booked: booked,
      assisted: assisted,
      avgRating: avgRating,
      numRatings: numRatings,
      venueId: venueId,
      organizerId: organizerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

