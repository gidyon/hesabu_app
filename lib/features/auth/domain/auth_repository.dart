abstract class AuthRepository {
  Future<bool> login(String email, String password);
  Future<bool> register(String fullName, String email, String phone, String password);
  Future<bool> sendResetCode(String email);
  Future<bool> verifyResetCode(String email, String code);
  Future<bool> resetPassword(String email, String newPassword);
}
