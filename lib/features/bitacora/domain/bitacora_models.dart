import '../../../shared/models/pagination_meta.dart';

class BitacoraItem {
  final String idActivityLog;
  final String accion;
  final String entidad;
  final String? entidadId;
  final dynamic detalle;
  final String fechaHora;
  final String? ipOrigen;
  final String? idUsuario;
  final String? username;
  final String? email;

  const BitacoraItem({
    required this.idActivityLog,
    required this.accion,
    required this.entidad,
    required this.entidadId,
    required this.detalle,
    required this.fechaHora,
    required this.ipOrigen,
    required this.idUsuario,
    required this.username,
    required this.email,
  });

  factory BitacoraItem.fromJson(Map<String, dynamic> json) {
    return BitacoraItem(
      idActivityLog: (json['id_activity_log'] ?? '').toString(),
      accion: (json['accion'] ?? '') as String,
      entidad: (json['entidad'] ?? '') as String,
      entidadId: json['entidad_id']?.toString(),
      detalle: json['detalle'],
      fechaHora: (json['fecha_hora'] ?? '') as String,
      ipOrigen: json['ip_origen'] as String?,
      idUsuario: json['id_usuario']?.toString(),
      username: json['username'] as String?,
      email: json['email'] as String?,
    );
  }
}

class BitacoraQuery {
  final int page;
  final int limit;
  final String accion;
  final String entidad;
  final String entidadId;
  final String idUsuario;
  final String fechaDesde;
  final String fechaHasta;

  const BitacoraQuery({
    this.page = 1,
    this.limit = 20,
    this.accion = '',
    this.entidad = '',
    this.entidadId = '',
    this.idUsuario = '',
    this.fechaDesde = '',
    this.fechaHasta = '',
  });

  BitacoraQuery copyWith({
    int? page,
    int? limit,
    String? accion,
    String? entidad,
    String? entidadId,
    String? idUsuario,
    String? fechaDesde,
    String? fechaHasta,
  }) {
    return BitacoraQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      accion: accion ?? this.accion,
      entidad: entidad ?? this.entidad,
      entidadId: entidadId ?? this.entidadId,
      idUsuario: idUsuario ?? this.idUsuario,
      fechaDesde: fechaDesde ?? this.fechaDesde,
      fechaHasta: fechaHasta ?? this.fechaHasta,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (accion.trim().isNotEmpty) 'accion': accion.trim(),
      if (entidad.trim().isNotEmpty) 'entidad': entidad.trim(),
      if (entidadId.trim().isNotEmpty) 'entidad_id': entidadId.trim(),
      if (idUsuario.trim().isNotEmpty) 'id_usuario': idUsuario.trim(),
      if (fechaDesde.trim().isNotEmpty) 'fecha_desde': fechaDesde.trim(),
      if (fechaHasta.trim().isNotEmpty) 'fecha_hasta': fechaHasta.trim(),
    };
  }
}

class BitacoraListResponse {
  final List<BitacoraItem> data;
  final PaginationMeta meta;

  const BitacoraListResponse({
    required this.data,
    required this.meta,
  });

  factory BitacoraListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => BitacoraItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return BitacoraListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}
