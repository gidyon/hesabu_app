import 'package:hesabu_app/core/network/auth_local_data_source.dart';
import 'package:hesabu_app/features/auth/data/auth_remote_data_source.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      if (response.status == 'success' || response.accessToken.isNotEmpty) {
        await localDataSource.saveToken(response.accessToken);
        await localDataSource.saveUser(response.user.toJson());
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
    try {
      List<String> names = fullName.split(' ');
      String firstName = names.isNotEmpty ? names.first : 'User';
      String otherNames = names.length > 1
          ? names.sublist(1).join(' ')
          : 'Name';

      await remoteDataSource.register(
        firstName,
        otherNames,
        phone,
        password,
      );

      return true; // if no error was thrown, consider it success
    } catch (e) {
      return false;
    }
  }

  // Mocks for endpoints not in postman collection
  @override
  Future<bool> sendResetCode(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> verifyResetCode(String email, String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == '1234';
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<void> setOnboarded() async {
    await localDataSource.setOnboarded();
  }

  @override
  bool hasSeenOnboarding() {
    return localDataSource.hasSeenOnboarding();
  }

  @override
  bool isSessionValid() {
    return localDataSource.isTokenValid();
  }
}
