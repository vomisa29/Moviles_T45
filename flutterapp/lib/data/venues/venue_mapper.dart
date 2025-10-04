import '../../../domain/venues/venue.dart';
import 'venue_dto.dart';


class VenueMapper {

  static Venue toDomain(VenueDto dto) {
    return Venue(
      id: dto.id,
      name: dto.name,
      latitude: dto.latitude,
      longitude: dto.longitude,
      capacity: dto.capacity,
      bookingCount: dto.bookingCount,
    );
  }

  static VenueDto fromDomain(Venue venue) {
    return VenueDto(
      id: venue.id,
      name: venue.name,
      latitude: venue.latitude,
      longitude: venue.longitude,
      capacity: venue.capacity,
      bookingCount: venue.bookingCount,
    );
  }

  static List<Venue> toDomainList(List<VenueDto> dtos) =>
      dtos.map(toDomain).toList(growable: false);

  static List<VenueDto> fromDomainList(List<Venue> venues) =>
      venues.map(fromDomain).toList(growable: false);
}
