import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _storage;

  SecureTokenStorage(this._storage);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() => _storage.delete(key: _refreshTokenKey);
}