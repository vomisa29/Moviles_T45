enum UserRole { user, admin}


UserRole roleFromString(String? role) {
  switch (role?.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    default:
      return UserRole.user;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return 'admin';
    case UserRole.user:
      return 'user';
  }
}

class User {
  final String uid;
  final String? username;
  final String email;
  final String? description;
  final UserRole role;
  final DateTime? createdAt;
  final List<String>? sportList;
  final double? avgRating;
  final int? numRating;
  final double? assistanceRate;

  const User({
    required this.uid,
    this.username,
    required this.email,
    this.description,
    required this.role,
    this.createdAt,
    this.sportList,
    this.avgRating,
    this.numRating,
    this.assistanceRate,
  });
}
