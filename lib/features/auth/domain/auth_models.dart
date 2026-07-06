import '../../../shared/models/tipo_rol.dart';

class AuthUser {
  final String id;
  final String email;
  final String username;
  final TipoRol? rol;

  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    required this.rol,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      email: (json['email'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      rol: tipoRolFromInt(json['rol'] as int?),
    );
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: (json['access_token'] ?? '') as String,
      refreshToken: (json['refresh_token'] ?? '') as String,
      user: AuthUser.fromJson(json['usuario'] as Map<String, dynamic>),
    );
  }
}
