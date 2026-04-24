abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<bool> register(
    String fullName,
    String email,
    String phone,
    String password,
  );
  Future<bool> sendResetCode(String msisdn);
  Future<bool> verifyResetCode(String msisdn, String code);
  Future<bool> resetPassword(String msisdn, String otp, String newPassword);
  Future<Map<String, dynamic>?> getUser();
  Future<void> setOnboarded();
  bool hasSeenOnboarding();
  bool isSessionValid();
  Future<String?> getLastLoginIdentifier();
  Future<void> logout();
}
