enum UserRole { user, admin, organizer }


UserRole roleFromString(String? role) {
  switch (role?.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'organizer':
      return UserRole.organizer;
    case 'user':
    default:
      return UserRole.user;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.organizer:
      return 'organizer';
    case UserRole.user:
      return 'user';
  }
}

class User {
  final String uid;
  final String username;
  final String email;
  final String description;
  final UserRole role;
  final DateTime createdAt;
  final List<String> sportList;
  final double avgRating;
  final int numRating;
  final double assistanceRate;

  const User({
    required this.uid,
    required this.username,
    required this.email,
    required this.description,
    required this.role,
    required this.createdAt,
    required this.sportList,
    required this.avgRating,
    required this.numRating,
    required this.assistanceRate,
  });
}
