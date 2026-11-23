import '../../../shared/models/pagination_meta.dart';

class AsignacionItem {
  final String idAsignacionActivo;
  final String fechaInicio;
  final String? fechaFin;
  final String estado;
  final String? observacion;
  final String idActivo;
  final String etiquetaActivo;
  final String idPdv;
  final String nombrePdv;

  const AsignacionItem({
    required this.idAsignacionActivo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.observacion,
    required this.idActivo,
    required this.etiquetaActivo,
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
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombrePdv: (json['nombre_pdv'] ?? '') as String,
    );
  }
}

class AsignacionesQuery {
  final int page;
  final int limit;
  final String idActivo;
  final String etiqueta;
  final String idPdv;
  final String pdv;
  final bool? activa;
  final String estado;

  const AsignacionesQuery({
    this.page = 1,
    this.limit = 20,
    this.idActivo = '',
    this.etiqueta = '',
    this.idPdv = '',
    this.pdv = '',
    this.activa,
    this.estado = '',
  });

  AsignacionesQuery copyWith({
    int? page,
    int? limit,
    String? idActivo,
    String? etiqueta,
    String? idPdv,
    String? pdv,
    bool? activa,
    bool clearActiva = false,
    String? estado,
  }) {
    return AsignacionesQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      idActivo: idActivo ?? this.idActivo,
      etiqueta: etiqueta ?? this.etiqueta,
      idPdv: idPdv ?? this.idPdv,
      pdv: pdv ?? this.pdv,
      activa: clearActiva ? null : (activa ?? this.activa),
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (idActivo.trim().isNotEmpty) 'id_activo': idActivo.trim(),
      if (etiqueta.trim().isNotEmpty) 'etiqueta': etiqueta.trim(),
      if (idPdv.trim().isNotEmpty) 'id_pdv': idPdv.trim(),
      if (pdv.trim().isNotEmpty) 'pdv': pdv.trim(),
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

class PdvOption {
  final String idPdv;
  final String nombreNegocio;
  final bool activo;

  const PdvOption({
    required this.idPdv,
    required this.nombreNegocio,
    required this.activo,
  });

  factory PdvOption.fromJson(Map<String, dynamic> json) {
    return PdvOption(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      activo: (json['activo'] ?? false) as bool,
    );
  }
}
