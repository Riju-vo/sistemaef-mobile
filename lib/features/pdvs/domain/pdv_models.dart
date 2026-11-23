import '../../../shared/models/pagination_meta.dart';

enum Supracanal { onPremise, offPremise }

Supracanal? supracanalFromApiNullable(String? value) {
  switch ((value ?? '').trim()) {
    case 'OnPremise':
      return Supracanal.onPremise;
    case 'OffPremise':
      return Supracanal.offPremise;
    default:
      return null;
  }
}

String supracanalToApi(Supracanal value) {
  switch (value) {
    case Supracanal.onPremise:
      return 'OnPremise';
    case Supracanal.offPremise:
      return 'OffPremise';
  }
}

class PdvItem {
  final String idPdv;
  final String nombreNegocio;
  final String? direccion;
  final String direccionId;
  final double? latitud;
  final double? longitud;
  final String? nit;
  final String? telefono;
  final String tipoCanal;
  final Supracanal? supracanal;
  final bool activo;
  final String? sucursal;
  final String? provincia;
  final String? subcanal;
  final String? estadoPdv;

  const PdvItem({
    required this.idPdv,
    required this.nombreNegocio,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.nit,
    required this.telefono,
    required this.tipoCanal,
    required this.supracanal,
    required this.activo,
    required this.sucursal,
    required this.provincia,
    required this.subcanal,
    required this.estadoPdv,
  });

  factory PdvItem.fromJson(Map<String, dynamic> json) {
    return PdvItem(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      direccion: json['direccion'] as String?,
      direccionId: (json['direccion_id'] ?? '').toString(),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      nit: json['nit'] as String?,
      telefono: json['telefono'] as String?,
      tipoCanal: (json['tipo_canal'] ?? '') as String,
      supracanal: supracanalFromApiNullable(json['supracanal'] as String?),
      activo: (json['activo'] ?? false) as bool,
      sucursal: json['sucursal'] as String?,
      provincia: json['provincia'] as String?,
      subcanal: json['subcanal'] as String?,
      estadoPdv: json['estado_pdv'] as String?,
    );
  }
}

class PdvsQuery {
  final int page;
  final int limit;
  final String nombreNegocio;
  final String nit;
  final String direccionId;
  final String tipoCanal;
  final Supracanal? supracanal;
  final bool? activo;

  const PdvsQuery({
    this.page = 1,
    this.limit = 20,
    this.nombreNegocio = '',
    this.nit = '',
    this.direccionId = '',
    this.tipoCanal = '',
    this.supracanal,
    this.activo = true,
  });

  PdvsQuery copyWith({
    int? page,
    int? limit,
    String? nombreNegocio,
    String? nit,
    String? direccionId,
    String? tipoCanal,
    Supracanal? supracanal,
    bool clearSupracanal = false,
    bool? activo,
    bool clearActivo = false,
  }) {
    return PdvsQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      nombreNegocio: nombreNegocio ?? this.nombreNegocio,
      nit: nit ?? this.nit,
      direccionId: direccionId ?? this.direccionId,
      tipoCanal: tipoCanal ?? this.tipoCanal,
      supracanal: clearSupracanal ? null : (supracanal ?? this.supracanal),
      activo: clearActivo ? null : (activo ?? this.activo),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (nombreNegocio.trim().isNotEmpty)
        'nombre_negocio': nombreNegocio.trim(),
      if (nit.trim().isNotEmpty) 'nit': nit.trim(),
      if (direccionId.trim().isNotEmpty) 'direccion_id': direccionId.trim(),
      if (tipoCanal.trim().isNotEmpty) 'tipo_canal': tipoCanal.trim(),
      if (supracanal != null) 'supracanal': supracanalToApi(supracanal!),
      if (activo != null) 'activo': activo,
    };
  }
}

class PdvsListResponse {
  final List<PdvItem> data;
  final PaginationMeta meta;

  const PdvsListResponse({
    required this.data,
    required this.meta,
  });

  factory PdvsListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => PdvItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return PdvsListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

class PdvUpsertPayload {
  final String nombreNegocio;
  final String? direccion;
  final String direccionId;
  final double? latitud;
  final double? longitud;
  final String? nit;
  final String? telefono;
  final String tipoCanal;
  final Supracanal supracanal;
  final String? sucursal;
  final String? provincia;
  final String? subcanal;
  final String? estadoPdv;

  const PdvUpsertPayload({
    required this.nombreNegocio,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.nit,
    required this.telefono,
    required this.tipoCanal,
    required this.supracanal,
    required this.sucursal,
    required this.provincia,
    required this.subcanal,
    required this.estadoPdv,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_negocio': nombreNegocio.trim(),
      if ((direccion ?? '').trim().isNotEmpty) 'direccion': direccion!.trim(),
      'direccion_id': direccionId.trim(),
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if ((nit ?? '').trim().isNotEmpty) 'nit': nit!.trim(),
      if ((telefono ?? '').trim().isNotEmpty) 'telefono': telefono!.trim(),
      'tipo_canal': tipoCanal.trim(),
      'supracanal': supracanalToApi(supracanal),
      if ((sucursal ?? '').trim().isNotEmpty) 'sucursal': sucursal!.trim(),
      if ((provincia ?? '').trim().isNotEmpty) 'provincia': provincia!.trim(),
      if ((subcanal ?? '').trim().isNotEmpty) 'subcanal': subcanal!.trim(),
      if ((estadoPdv ?? '').trim().isNotEmpty) 'estado_pdv': estadoPdv!.trim(),
    };
  }
}
