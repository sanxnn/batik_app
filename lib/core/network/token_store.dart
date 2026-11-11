import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the current token in memory for Dio and persists it in platform storage.
class TokenStore {
  TokenStore._();
  static final instance = TokenStore._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  String? get token => _token;

  Future<void> init() async {
    _token = await _storage.read(key: 'auth_token');

    // One-time migration from earlier versions that used SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString('token');
    if ((_token == null || _token!.isEmpty) &&
        legacy != null &&
        legacy.isNotEmpty) {
      await _storage.write(key: 'auth_token', value: legacy);
      _token = legacy;
    }
    if (legacy != null) await prefs.remove('token');
  }

  Future<void> save(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    _token = token;
  }

  Future<void> clear() async {
    _token = null;
    await _storage.delete(key: 'auth_token');
  }
}
