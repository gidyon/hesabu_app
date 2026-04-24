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

  String _formatMsisdn(String input) {
    String formatted = input.trim().replaceAll(' ', '');
    // Check if it's purely digits (or starts with +)
    if (RegExp(r'^\+?[0-9]+$').hasMatch(formatted)) {
      if (formatted.startsWith('0')) {
        return '254${formatted.substring(1)}';
      }
      if (formatted.startsWith('+254')) {
        return formatted.substring(1);
      }
    }
    return formatted;
  }

  @override
  Future<bool> login(String email, String password) async {
    try {
      final formattedIdentifier = _formatMsisdn(email);
      final response = await remoteDataSource.login(
        formattedIdentifier,
        password,
      );
      if (response.status == 'success' || response.accessToken.isNotEmpty) {
        await localDataSource.saveToken(response.accessToken);
        await localDataSource.saveUser(response.user.toJson());
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
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
      final formattedPhone = _formatMsisdn(phone);
      final trimmedFullName = fullName.trim();
      List<String> names = trimmedFullName.split(RegExp(r'\s+'));
      String firstName = names.isNotEmpty ? names.first : 'User';
      String otherNames = names.length > 1
          ? names.sublist(1).join(' ')
          : 'Name';

      await remoteDataSource.register(
        firstName,
        otherNames,
        formattedPhone,
        password,
      );

      return true; // if no error was thrown, consider it success
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> sendResetCode(String msisdn) async {
    final formattedMsisdn = _formatMsisdn(msisdn);
    return await remoteDataSource.sendResetCode(formattedMsisdn);
  }

  @override
  Future<bool> verifyResetCode(String msisdn, String code) async {
    // Just a local verification or placeholder if needed.
    // The actual API reset checks both OTP and new password together.
    return code.length >= 4;
  }

  @override
  Future<bool> resetPassword(
    String msisdn,
    String otp,
    String newPassword,
  ) async {
    final formattedMsisdn = _formatMsisdn(msisdn);
    return await remoteDataSource.resetPassword(
      formattedMsisdn,
      otp,
      newPassword,
    );
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    return localDataSource.getUser();
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

  @override
  Future<String?> getLastLoginIdentifier() async {
    final user = await localDataSource.getUser();
    return user?['msisdn']?.toString() ?? user?['email']?.toString();
  }

  @override
  Future<void> logout() async {
    await localDataSource.logout();
  }
}
