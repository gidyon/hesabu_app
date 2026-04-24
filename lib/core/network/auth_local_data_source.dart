import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_profile';
  static const String _onboardedKey = 'has_onboarded';
  static const String _lastLoginKey = 'last_login_timestamp';

  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  AuthLocalDataSource({required this.sharedPreferences});

  Future<void> saveToken(String token) async {
    await sharedPreferences.setInt(
      _lastLoginKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: _tokenKey);
  }

  Future<bool> saveUser(Map<String, dynamic> userJson) async {
    return await sharedPreferences.setString(_userKey, json.encode(userJson));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final userString = sharedPreferences.getString(_userKey);
    if (userString != null) {
      return json.decode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> clearUser() async {
    return await sharedPreferences.remove(_userKey);
  }

  Future<bool> setOnboarded() async {
    return await sharedPreferences.setBool(_onboardedKey, true);
  }

  bool hasSeenOnboarding() {
    return sharedPreferences.getBool(_onboardedKey) ?? false;
  }

  bool isTokenValid() {
    final lastLogin = sharedPreferences.getInt(_lastLoginKey);
    if (lastLogin == null) return false;

    final lastLoginDate = DateTime.fromMillisecondsSinceEpoch(lastLogin);
    final now = DateTime.now();
    final difference = now.difference(lastLoginDate).inMinutes;

    return difference < 30;
  }

  Future<void> logout() async {
    await secureStorage.delete(key: _tokenKey);
    await sharedPreferences.remove(_lastLoginKey);
    await sharedPreferences.remove(_userKey);
  }
}
