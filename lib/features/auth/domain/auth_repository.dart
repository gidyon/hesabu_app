import 'package:hesabu_app/core/api/api_response.dart';

abstract class AuthRepository {
  Future<ApiResponse<bool>> login(String email, String password);
  Future<ApiResponse<bool>> register(
    String fullName,
    String email,
    String phone,
    String password,
  );
  Future<ApiResponse<bool>> sendResetCode(String msisdn);
  Future<ApiResponse<bool>> verifyResetCode(String msisdn, String code);
  Future<ApiResponse<bool>> resetPassword(
    String msisdn,
    String otp,
    String newPassword,
  );
  Future<Map<String, dynamic>?> getUser();
  Future<void> setOnboarded();
  bool hasSeenOnboarding();
  bool isSessionValid();
  Future<String?> getLastLoginIdentifier();
  Future<void> logout();
}
