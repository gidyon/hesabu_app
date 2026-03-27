import 'package:hesabu_app/core/network/auth_local_data_source.dart';
import 'package:hesabu_app/features/settings/data/models/settings_models.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AuthLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final userJson = await localDataSource.getUser();
      if (userJson != null) {
        final model = SettingsUserModel.fromJson(userJson);
        final name = [
          model.firstName,
          model.otherNames,
        ].where((e) => e != null && e.isNotEmpty).join(' ');

        return UserProfile(
          name: name.isNotEmpty ? name : 'User',
          firstName: model.firstName ?? '',
          otherNames: model.otherNames ?? '',
          msisdn: model.msisdn ?? '',
          membershipType: 'Standard Member',
          activeGroupName: 'My Groups',
          avatarUrl:
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        );
      }
      return UserProfile(
        name: 'Guest User',
        firstName: '',
        otherNames: '',
        msisdn: '',
        membershipType: 'None',
        activeGroupName: 'No Active Group',
        avatarUrl: '',
      );
    } catch (e) {
      return UserProfile(
        name: 'Guest User',
        firstName: '',
        otherNames: '',
        msisdn: '',
        membershipType: 'None',
        activeGroupName: 'No Active Group',
        avatarUrl: '',
      );
    }
  }

  @override
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final userJson = await localDataSource.getUser();
      if (userJson != null) {
        final updatedUser = Map<String, dynamic>.from(userJson);
        updatedUser['first_name'] = profileData['first_name'];
        updatedUser['other_names'] = profileData['other_names'];
        updatedUser['msisdn'] = profileData['msisdn'];

        await localDataSource.saveUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
