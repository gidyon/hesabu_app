class UserProfile {
  final String name;
  final String membershipType;
  final String activeGroupName;
  final String avatarUrl;
  final String firstName;
  final String otherNames;
  final String msisdn;

  UserProfile({
    required this.name,
    required this.membershipType,
    required this.activeGroupName,
    required this.avatarUrl,
    required this.firstName,
    required this.otherNames,
    required this.msisdn,
  });
}

abstract class SettingsRepository {
  Future<UserProfile> getUserProfile();
  Future<bool> updateProfile(Map<String, dynamic> profileData);
}
