import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityController with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _biometricEnabled = false;

  SecurityController() {
    _loadSettings();
  }

  bool get biometricEnabled => _biometricEnabled;

  Future<void> _loadSettings() async {
    final enabled = await _storage.read(key: 'bio_enabled');
    _biometricEnabled = enabled == 'true';
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(key: 'bio_enabled', value: value.toString());
    _biometricEnabled = value;
    notifyListeners();
  }
}
