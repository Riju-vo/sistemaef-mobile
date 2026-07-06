import '../../../shared/models/pagination_meta.dart';

class ActivoItem {
  final String idActivo;
  final String serial;
  final String etiqueta;
  final int idDescripcionEquipo;
  final String descripcionEquipo;
  final String? fabricante;
  final String? modelo;
  final String? anioFabricacion;
  final String? provincia;
  final String? observacion;
  final bool activo;
  final int idTipoActivo;
  final String tipoActivo;
  final int idEstadoActivo;
  final String estadoActivo;

  const ActivoItem({
    required this.idActivo,
    required this.serial,
    required this.etiqueta,
    required this.idDescripcionEquipo,
    required this.descripcionEquipo,
    required this.fabricante,
    required this.modelo,
    required this.anioFabricacion,
    required this.provincia,
    required this.observacion,
    required this.activo,
    required this.idTipoActivo,
    required this.tipoActivo,
    required this.idEstadoActivo,
    required this.estadoActivo,
  });

  factory ActivoItem.fromJson(Map<String, dynamic> json) {
    return ActivoItem(
      idActivo: (json['id_activo'] ?? '').toString(),
      serial: (json['serial'] ?? '') as String,
      etiqueta: (json['etiqueta'] ?? '') as String,
      idDescripcionEquipo: (json['id_descripcion_equipo'] ?? 0) as int,
      descripcionEquipo: (json['descripcion_equipo'] ?? '') as String,
      fabricante: json['fabricante'] as String?,
      modelo: json['modelo'] as String?,
      anioFabricacion: json['anio_fabricacion'] as String?,
      provincia: json['provincia'] as String?,
      observacion: json['observacion'] as String?,
      activo: (json['activo'] ?? false) as bool,
      idTipoActivo: (json['id_tipo_activo'] ?? 0) as int,
      tipoActivo: (json['tipo_activo'] ?? '') as String,
      idEstadoActivo: (json['id_estado_activo'] ?? 0) as int,
      estadoActivo: (json['estado_activo'] ?? '') as String,
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

class ActivoUpsertPayload {
  final String serial;
  final String etiqueta;
  final int idDescripcionEquipo;
  final String? fabricante;
  final String? modelo;
  final String? anioFabricacion;
  final String? provincia;
  final String? observacion;
  final bool activo;
  final int idTipoActivo;
  final int idEstadoActivo;

  const ActivoUpsertPayload({
    required this.serial,
    required this.etiqueta,
    required this.idDescripcionEquipo,
    required this.fabricante,
    required this.modelo,
    required this.anioFabricacion,
    required this.provincia,
    required this.observacion,
    required this.activo,
    required this.idTipoActivo,
    required this.idEstadoActivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'serial': serial.trim(),
      'etiqueta': etiqueta.trim(),
      'id_descripcion_equipo': idDescripcionEquipo,
      'fabricante': _optionalText(fabricante),
      'modelo': _optionalText(modelo),
      'anio_fabricacion': _optionalText(anioFabricacion),
      'provincia': _optionalText(provincia),
      'observacion': _optionalText(observacion),
      'activo': activo,
      'id_tipo_activo': idTipoActivo,
      'id_estado_activo': idEstadoActivo,
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

class ClienteAsignado {
  final String idCliente;
  final String codigoCliente;
  final String nombre;
  final String? telefono;
  final String categoriaSofia;
  final String? direccion;
  final double? latitud;
  final double? longitud;

  const ClienteAsignado({
    required this.idCliente,
    required this.codigoCliente,
    required this.nombre,
    required this.telefono,
    required this.categoriaSofia,
    required this.direccion,
    required this.latitud,
    required this.longitud,
  });

  factory ClienteAsignado.fromJson(Map<String, dynamic> json) {
    return ClienteAsignado(
      idCliente: (json['id_cliente'] ?? '').toString(),
      codigoCliente: (json['codigo_cliente'] ?? '').toString(),
      nombre: (json['nombre'] ?? '') as String,
      telefono: json['telefono'] as String?,
      categoriaSofia: (json['categoria_sofia'] ?? '') as String,
      direccion: json['direccion'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
    );
  }
}

class PdvAsignado {
  final String idPdv;
  final String nombreNegocio;
  final String? direccion;
  final double? latitud;
  final double? longitud;
  final String? nit;
  final String supracanal;
  final String canal;

  const PdvAsignado({
    required this.idPdv,
    required this.nombreNegocio,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.nit,
    required this.supracanal,
    required this.canal,
  });

  factory PdvAsignado.fromJson(Map<String, dynamic> json) {
    return PdvAsignado(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      direccion: json['direccion'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      nit: json['nit'] as String?,
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
  final ClienteAsignado cliente;
  final PdvAsignado? pdv;

  const AsignacionActivaContexto({
    required this.idAsignacionActivo,
    required this.fechaInicio,
    required this.estado,
    required this.observacion,
    required this.cliente,
    required this.pdv,
  });

  factory AsignacionActivaContexto.fromJson(Map<String, dynamic> json) {
    return AsignacionActivaContexto(
      idAsignacionActivo: (json['id_asignacion_activo'] ?? '').toString(),
      fechaInicio: (json['fecha_inicio'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,
      observacion: json['observacion'] as String?,
      cliente: ClienteAsignado.fromJson(
        (json['cliente'] as Map).cast<String, dynamic>(),
      ),
      pdv: json['pdv'] == null
          ? null
          : PdvAsignado.fromJson((json['pdv'] as Map).cast<String, dynamic>()),
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
