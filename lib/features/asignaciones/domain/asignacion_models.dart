import '../../../shared/models/pagination_meta.dart';

class AsignacionItem {
  final String idAsignacionActivo;
  final String fechaInicio;
  final String? fechaFin;
  final String estado;
  final String? observacion;
  final String idActivo;
  final String etiquetaActivo;
  final String idCliente;
  final String nombreCliente;
  final String? idPdv;
  final String? nombrePdv;

  const AsignacionItem({
    required this.idAsignacionActivo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.observacion,
    required this.idActivo,
    required this.etiquetaActivo,
    required this.idCliente,
    required this.nombreCliente,
    required this.idPdv,
    required this.nombrePdv,
  });

  factory AsignacionItem.fromJson(Map<String, dynamic> json) {
    return AsignacionItem(
      idAsignacionActivo: (json['id_asignacion_activo'] ?? '').toString(),
      fechaInicio: (json['fecha_inicio'] ?? '') as String,
      fechaFin: json['fecha_fin'] as String?,
      estado: (json['estado'] ?? '') as String,
      observacion: json['observacion'] as String?,
      idActivo: (json['id_activo'] ?? '').toString(),
      etiquetaActivo: (json['etiqueta_activo'] ?? '') as String,
      idCliente: (json['id_cliente'] ?? '').toString(),
      nombreCliente: (json['nombre_cliente'] ?? '') as String,
      idPdv: json['id_pdv']?.toString(),
      nombrePdv: json['nombre_pdv'] as String?,
    );
  }
}

class AsignacionesQuery {
  final int page;
  final int limit;
  final String idActivo;
  final String idCliente;
  final String idPdv;
  final bool? activa;
  final String estado;

  const AsignacionesQuery({
    this.page = 1,
    this.limit = 20,
    this.idActivo = '',
    this.idCliente = '',
    this.idPdv = '',
    this.activa,
    this.estado = '',
  });

  AsignacionesQuery copyWith({
    int? page,
    int? limit,
    String? idActivo,
    String? idCliente,
    String? idPdv,
    bool? activa,
    bool clearActiva = false,
    String? estado,
  }) {
    return AsignacionesQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      idActivo: idActivo ?? this.idActivo,
      idCliente: idCliente ?? this.idCliente,
      idPdv: idPdv ?? this.idPdv,
      activa: clearActiva ? null : (activa ?? this.activa),
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (idActivo.trim().isNotEmpty) 'id_activo': idActivo.trim(),
      if (idCliente.trim().isNotEmpty) 'id_cliente': idCliente.trim(),
      if (idPdv.trim().isNotEmpty) 'id_pdv': idPdv.trim(),
      if (activa != null) 'activa': activa,
      if (estado.trim().isNotEmpty) 'estado': estado.trim(),
    };
  }
}

class AsignacionesListResponse {
  final List<AsignacionItem> data;
  final PaginationMeta meta;

  const AsignacionesListResponse({
    required this.data,
    required this.meta,
  });

  factory AsignacionesListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => AsignacionItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return AsignacionesListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

class ClienteOption {
  final String idCliente;
  final String codigoCliente;
  final String nombre;
  final bool activo;

  const ClienteOption({
    required this.idCliente,
    required this.codigoCliente,
    required this.nombre,
    required this.activo,
  });

  factory ClienteOption.fromJson(Map<String, dynamic> json) {
    return ClienteOption(
      idCliente: (json['id_cliente'] ?? '').toString(),
      codigoCliente: (json['codigo_cliente'] ?? '').toString(),
      nombre: (json['nombre'] ?? '') as String,
      activo: (json['activo'] ?? false) as bool,
    );
  }
}

class PdvOption {
  final String idPdv;
  final String nombreNegocio;
  final String idCliente;
  final bool activo;

  const PdvOption({
    required this.idPdv,
    required this.nombreNegocio,
    required this.idCliente,
    required this.activo,
  });

  factory PdvOption.fromJson(Map<String, dynamic> json) {
    return PdvOption(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      idCliente: (json['id_cliente'] ?? '').toString(),
      activo: (json['activo'] ?? false) as bool,
    );
  }
}

class CatalogOption {
  final int id;
  final String nombre;

  const CatalogOption({
    required this.id,
    required this.nombre,
  });

  factory CatalogOption.fromJson(Map<String, dynamic> json) {
    return CatalogOption(
      id: (json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? '') as String,
    );
  }
}
