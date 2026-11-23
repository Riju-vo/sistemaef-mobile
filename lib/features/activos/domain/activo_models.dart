import '../../../shared/models/pagination_meta.dart';

class ActivoItem {
  final String idActivo;
  final String serial;
  final String etiqueta;
  final String descripcionEquipo;
  final String? fabricante;
  final String? modelo;
  final String? anioFabricacion;
  final String? provincia;
  final String? observacion;
  final bool activo;
  final String tipoActivo;
  final String estadoActivo;
  final String? sucursal;

  const ActivoItem({
    required this.idActivo,
    required this.serial,
    required this.etiqueta,
    required this.descripcionEquipo,
    required this.fabricante,
    required this.modelo,
    required this.anioFabricacion,
    required this.provincia,
    required this.observacion,
    required this.activo,
    required this.tipoActivo,
    required this.estadoActivo,
    required this.sucursal,
  });

  factory ActivoItem.fromJson(Map<String, dynamic> json) {
    return ActivoItem(
      idActivo: (json['id_activo'] ?? '').toString(),
      serial: (json['serial'] ?? '') as String,
      etiqueta: (json['etiqueta'] ?? '') as String,
      descripcionEquipo: (json['descripcion_equipo'] ?? '') as String,
      fabricante: json['fabricante'] as String?,
      modelo: json['modelo'] as String?,
      anioFabricacion: json['anio_fabricacion'] as String?,
      provincia: json['provincia'] as String?,
      observacion: json['observacion'] as String?,
      activo: (json['activo'] ?? false) as bool,
      tipoActivo: (json['tipo_activo'] ?? '') as String,
      estadoActivo: (json['estado_activo'] ?? '') as String,
      sucursal: json['sucursal'] as String?,
    );
  }
}

class ActivoUpsertPayload {
  final String serial;
  final String etiqueta;
  final String descripcionEquipo;
  final String? fabricante;
  final String? modelo;
  final String? anioFabricacion;
  final String? provincia;
  final String? observacion;
  final bool activo;
  final String tipoActivo;
  final String estadoActivo;
  final String? sucursal;

  const ActivoUpsertPayload({
    required this.serial,
    required this.etiqueta,
    required this.descripcionEquipo,
    required this.fabricante,
    required this.modelo,
    required this.anioFabricacion,
    required this.provincia,
    required this.observacion,
    required this.activo,
    required this.tipoActivo,
    required this.estadoActivo,
    required this.sucursal,
  });

  Map<String, dynamic> toJson() {
    return {
      'serial': serial.trim(),
      'etiqueta': etiqueta.trim(),
      'descripcion_equipo': descripcionEquipo.trim(),
      'fabricante': _optionalText(fabricante),
      'modelo': _optionalText(modelo),
      'anio_fabricacion': _optionalText(anioFabricacion),
      'provincia': _optionalText(provincia),
      'observacion': _optionalText(observacion),
      'activo': activo,
      'tipo_activo': tipoActivo.trim(),
      'estado_activo': estadoActivo.trim(),
      'sucursal': _optionalText(sucursal),
    };
  }
}

class ActivosQuery {
  final int page;
  final int limit;
  final String etiqueta;
  final String provincia;
  final String modelo;
  final String fabricante;
  final bool? activo;

  const ActivosQuery({
    this.page = 1,
    this.limit = 20,
    this.etiqueta = '',
    this.provincia = '',
    this.modelo = '',
    this.fabricante = '',
    this.activo,
  });

  ActivosQuery copyWith({
    int? page,
    int? limit,
    String? etiqueta,
    String? provincia,
    String? modelo,
    String? fabricante,
    bool? activo,
    bool clearActivo = false,
  }) {
    return ActivosQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      etiqueta: etiqueta ?? this.etiqueta,
      provincia: provincia ?? this.provincia,
      modelo: modelo ?? this.modelo,
      fabricante: fabricante ?? this.fabricante,
      activo: clearActivo ? null : (activo ?? this.activo),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (etiqueta.trim().isNotEmpty) 'etiqueta': etiqueta.trim(),
      if (provincia.trim().isNotEmpty) 'provincia': provincia.trim(),
      if (modelo.trim().isNotEmpty) 'modelo': modelo.trim(),
      if (fabricante.trim().isNotEmpty) 'fabricante': fabricante.trim(),
      if (activo != null) 'activo': activo,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ActivosQuery &&
        other.page == page &&
        other.limit == limit &&
        other.etiqueta == etiqueta &&
        other.provincia == provincia &&
        other.modelo == modelo &&
        other.fabricante == fabricante &&
        other.activo == activo;
  }

  @override
  int get hashCode =>
      Object.hash(page, limit, etiqueta, provincia, modelo, fabricante, activo);
}

class ActivosListResponse {
  final List<ActivoItem> data;
  final PaginationMeta meta;

  const ActivosListResponse({
    required this.data,
    required this.meta,
  });

  factory ActivosListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => ActivoItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return ActivosListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

class PdvAsignado {
  final String idPdv;
  final String nombreNegocio;
  final String? direccion;
  final String direccionId;
  final double? latitud;
  final double? longitud;
  final String? nit;
  final String? telefono;
  final String supracanal;
  final String canal;

  const PdvAsignado({
    required this.idPdv,
    required this.nombreNegocio,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.nit,
    required this.telefono,
    required this.supracanal,
    required this.canal,
  });

  factory PdvAsignado.fromJson(Map<String, dynamic> json) {
    return PdvAsignado(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      direccion: json['direccion'] as String?,
      direccionId: (json['direccion_id'] ?? '').toString(),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      nit: json['nit'] as String?,
      telefono: json['telefono'] as String?,
      supracanal: (json['supracanal'] ?? '') as String,
      canal: (json['canal'] ?? '') as String,
    );
  }
}

class AsignacionActivaContexto {
  final String idAsignacionActivo;
  final String fechaInicio;
  final String estado;
  final String? observacion;
  final PdvAsignado pdv;

  const AsignacionActivaContexto({
    required this.idAsignacionActivo,
    required this.fechaInicio,
    required this.estado,
    required this.observacion,
    required this.pdv,
  });

  factory AsignacionActivaContexto.fromJson(Map<String, dynamic> json) {
    return AsignacionActivaContexto(
      idAsignacionActivo: (json['id_asignacion_activo'] ?? '').toString(),
      fechaInicio: (json['fecha_inicio'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,
      observacion: json['observacion'] as String?,
      pdv: PdvAsignado.fromJson((json['pdv'] as Map).cast<String, dynamic>()),
    );
  }
}

class ActivoContextoOperativo {
  final ActivoItem activo;
  final AsignacionActivaContexto? asignacionActiva;

  const ActivoContextoOperativo({
    required this.activo,
    required this.asignacionActiva,
  });

  factory ActivoContextoOperativo.fromJson(Map<String, dynamic> json) {
    return ActivoContextoOperativo(
      activo: ActivoItem.fromJson((json['activo'] as Map).cast<String, dynamic>()),
      asignacionActiva: json['asignacion_activa'] == null
          ? null
          : AsignacionActivaContexto.fromJson(
              (json['asignacion_activa'] as Map).cast<String, dynamic>(),
            ),
    );
  }
}

String? _optionalText(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
