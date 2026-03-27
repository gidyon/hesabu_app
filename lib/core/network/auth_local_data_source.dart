import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_profile';
  static const String _onboardedKey = 'has_onboarded';
  static const String _lastLoginKey = 'last_login_timestamp';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({required this.sharedPreferences});

  Future<bool> saveToken(String token) async {
    await sharedPreferences.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
    return await sharedPreferences.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return sharedPreferences.getString(_tokenKey);
  }

  Future<bool> clearToken() async {
    return await sharedPreferences.remove(_tokenKey);
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
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_lastLoginKey);
    await sharedPreferences.remove(_userKey);
  }
}
