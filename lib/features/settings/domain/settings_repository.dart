class UserProfile {
  final String name;
  final String membershipType;
  final String activeGroupName;
  final String avatarUrl;

  UserProfile({
    required this.name,
    required this.membershipType,
    required this.activeGroupName,
    required this.avatarUrl,
  });
}

abstract class SettingsRepository {
  Future<UserProfile> getUserProfile();
}
