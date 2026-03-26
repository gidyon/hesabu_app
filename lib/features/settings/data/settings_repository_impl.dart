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
        final name = [model.firstName, model.otherNames].where((e) => e != null && e.isNotEmpty).join(' ');

        return UserProfile(
          name: name.isNotEmpty ? name : 'User',
          membershipType: 'Standard Member', // Default as it's not in the response
          activeGroupName: 'My Groups', // Default or fetch logic
          avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        );
      }
      return UserProfile(
        name: 'Guest User',
        membershipType: 'None',
        activeGroupName: 'No Active Group',
        avatarUrl: '',
      );
    } catch (e) {
      return UserProfile(
        name: 'Guest User',
        membershipType: 'None',
        activeGroupName: 'No Active Group',
        avatarUrl: '',
      );
    }
  }
}
