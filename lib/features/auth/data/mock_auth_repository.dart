import 'package:hesabu_app/features/auth/domain/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<bool> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // Mock success for any input for now
    return true;
  }

  @override
  Future<bool> register(String fullName, String email, String phone, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> sendResetCode(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  @override
  Future<bool> verifyResetCode(String email, String code) async {
    await Future.delayed(const Duration(seconds: 1));
    return code == "123456"; // Simple mock validation
  }

  @override
  Future<bool> resetPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
