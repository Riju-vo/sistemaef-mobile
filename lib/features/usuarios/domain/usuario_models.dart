import '../../../shared/models/pagination_meta.dart';

class RolOption {
  final int id;
  final String nombre;

  const RolOption({
    required this.id,
    required this.nombre,
  });

  factory RolOption.fromJson(Map<String, dynamic> json) {
    return RolOption(
      id: (json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? '') as String,
    );
  }
}

class UsuarioItem {
  final String idUsuario;
  final String username;
  final String email;
  final String createdAt;
  final String? lastActive;
  final bool activo;
  final int? tipoRol;
  final String? rol;

  const UsuarioItem({
    required this.idUsuario,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.lastActive,
    required this.activo,
    required this.tipoRol,
    required this.rol,
  });

  factory UsuarioItem.fromJson(Map<String, dynamic> json) {
    return UsuarioItem(
      idUsuario: (json['id_usuario'] ?? '').toString(),
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      createdAt: (json['created_at'] ?? '') as String,
      lastActive: json['last_active']?.toString(),
      activo: (json['activo'] ?? false) as bool,
      tipoRol: json['tipo_rol'] as int?,
      rol: json['rol'] as String?,
    );
  }
}

class UsuariosQuery {
  final int page;
  final int limit;
  final String username;
  final String email;
  final int? tipoRol;
  final bool? activo;

  const UsuariosQuery({
    this.page = 1,
    this.limit = 20,
    this.username = '',
    this.email = '',
    this.tipoRol,
    this.activo = true,
  });

  UsuariosQuery copyWith({
    int? page,
    int? limit,
    String? username,
    String? email,
    int? tipoRol,
    bool clearTipoRol = false,
    bool? activo,
    bool clearActivo = false,
  }) {
    return UsuariosQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      username: username ?? this.username,
      email: email ?? this.email,
      tipoRol: clearTipoRol ? null : (tipoRol ?? this.tipoRol),
      activo: clearActivo ? null : (activo ?? this.activo),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (username.trim().isNotEmpty) 'username': username.trim(),
      if (email.trim().isNotEmpty) 'email': email.trim(),
      if (tipoRol != null) 'tipo_rol': tipoRol,
      if (activo != null) 'activo': activo,
    };
  }
}

class UsuariosListResponse {
  final List<UsuarioItem> data;
  final PaginationMeta meta;

  const UsuariosListResponse({
    required this.data,
    required this.meta,
  });

  factory UsuariosListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => UsuarioItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return UsuariosListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

class UsuarioCreatePayload {
  final String username;
  final String email;
  final String password;
  final int? tipoRol;

  const UsuarioCreatePayload({
    required this.username,
    required this.email,
    required this.password,
    required this.tipoRol,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'email': email.trim(),
      'password': password.trim(),
      if (tipoRol != null) 'tipo_rol': tipoRol,
    };
  }
}

class UsuarioUpdatePayload {
  final String username;
  final String email;
  final String? password;
  final int? tipoRol;
  final bool clearTipoRol;

  const UsuarioUpdatePayload({
    required this.username,
    required this.email,
    required this.password,
    required this.tipoRol,
    required this.clearTipoRol,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'email': email.trim(),
      if ((password ?? '').trim().isNotEmpty) 'password': password!.trim(),
      if (clearTipoRol) 'tipo_rol': null,
      if (!clearTipoRol && tipoRol != null) 'tipo_rol': tipoRol,
    };
  }
}
