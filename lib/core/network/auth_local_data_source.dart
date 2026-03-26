import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_profile';

  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({required this.sharedPreferences});

  Future<bool> saveToken(String token) async {
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
}
