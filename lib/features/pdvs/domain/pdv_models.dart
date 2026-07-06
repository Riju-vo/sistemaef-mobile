import '../../../shared/models/pagination_meta.dart';
import '../../clientes/domain/cliente_models.dart';

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

class TipoCanalOption {
  final int id;
  final String nombre;

  const TipoCanalOption({
    required this.id,
    required this.nombre,
  });

  factory TipoCanalOption.fromJson(Map<String, dynamic> json) {
    return TipoCanalOption(
      id: (json['id'] ?? 0) as int,
      nombre: (json['nombre'] ?? '') as String,
    );
  }
}

class PdvItem {
  final String idPdv;
  final String nombreNegocio;
  final String? direccion;
  final String? direccionId;
  final double? latitud;
  final double? longitud;
  final String? nit;
  final int idTipoCanal;
  final String tipoCanal;
  final Supracanal? supracanal;
  final bool activo;
  final String idCliente;
  final String clienteNombre;
  final String clienteCodigo;

  const PdvItem({
    required this.idPdv,
    required this.nombreNegocio,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.nit,
    required this.idTipoCanal,
    required this.tipoCanal,
    required this.supracanal,
    required this.activo,
    required this.idCliente,
    required this.clienteNombre,
    required this.clienteCodigo,
  });

  factory PdvItem.fromJson(Map<String, dynamic> json) {
    return PdvItem(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      direccion: json['direccion'] as String?,
      direccionId: json['direccion_id'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      nit: json['nit'] as String?,
      idTipoCanal: (json['id_tipo_canal'] ?? 0) as int,
      tipoCanal: (json['tipo_canal'] ?? '') as String,
      supracanal: supracanalFromApiNullable(json['supracanal'] as String?),
      activo: (json['activo'] ?? false) as bool,
      idCliente: (json['id_cliente'] ?? '').toString(),
      clienteNombre: (json['cliente_nombre'] ?? '') as String,
      clienteCodigo: (json['cliente_codigo'] ?? '').toString(),
    );
  }
}

class PdvsQuery {
  final int page;
  final int limit;
  final String idCliente;
  final String nombreNegocio;
  final String nit;
  final int? idTipoCanal;
  final Supracanal? supracanal;
  final bool? activo;

  const PdvsQuery({
    this.page = 1,
    this.limit = 20,
    this.idCliente = '',
    this.nombreNegocio = '',
    this.nit = '',
    this.idTipoCanal,
    this.supracanal,
    this.activo = true,
  });

  PdvsQuery copyWith({
    int? page,
    int? limit,
    String? idCliente,
    String? nombreNegocio,
    String? nit,
    int? idTipoCanal,
    bool clearTipoCanal = false,
    Supracanal? supracanal,
    bool clearSupracanal = false,
    bool? activo,
    bool clearActivo = false,
  }) {
    return PdvsQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      idCliente: idCliente ?? this.idCliente,
      nombreNegocio: nombreNegocio ?? this.nombreNegocio,
      nit: nit ?? this.nit,
      idTipoCanal: clearTipoCanal ? null : (idTipoCanal ?? this.idTipoCanal),
      supracanal: clearSupracanal ? null : (supracanal ?? this.supracanal),
      activo: clearActivo ? null : (activo ?? this.activo),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (idCliente.trim().isNotEmpty) 'id_cliente': idCliente.trim(),
      if (nombreNegocio.trim().isNotEmpty)
        'nombre_negocio': nombreNegocio.trim(),
      if (nit.trim().isNotEmpty) 'nit': nit.trim(),
      if (idTipoCanal != null) 'id_tipo_canal': idTipoCanal,
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
  final String? direccionId;
  final double? latitud;
  final double? longitud;
  final String? nit;
  final int idTipoCanal;
  final Supracanal supracanal;
  final String idCliente;

  const PdvUpsertPayload({
    required this.nombreNegocio,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.nit,
    required this.idTipoCanal,
    required this.supracanal,
    required this.idCliente,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_negocio': nombreNegocio.trim(),
      if ((direccion ?? '').trim().isNotEmpty) 'direccion': direccion!.trim(),
      if ((direccionId ?? '').trim().isNotEmpty)
        'direccion_id': direccionId!.trim(),
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if ((nit ?? '').trim().isNotEmpty) 'nit': nit!.trim(),
      'id_tipo_canal': idTipoCanal,
      'supracanal': supracanalToApi(supracanal),
      'id_cliente': idCliente.trim(),
    };
  }
}

class ClienteNuevoPayload {
  final String codigoCliente;
  final String nombre;
  final String? telefono;
  final CategoriaSofia categoriaSofia;
  final String? direccion;
  final String? direccionId;
  final double? latitud;
  final double? longitud;

  const ClienteNuevoPayload({
    required this.codigoCliente,
    required this.nombre,
    required this.telefono,
    required this.categoriaSofia,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
  });

  Map<String, dynamic> toJson() {
    return {
      'modo': 'nuevo',
      'codigo_cliente': codigoCliente.trim(),
      'nombre': nombre.trim(),
      if ((telefono ?? '').trim().isNotEmpty) 'telefono': telefono!.trim(),
      'categoria_sofia': categoriaSofiaToApi(categoriaSofia),
      if ((direccion ?? '').trim().isNotEmpty) 'direccion': direccion!.trim(),
      if ((direccionId ?? '').trim().isNotEmpty)
        'direccion_id': direccionId!.trim(),
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
    };
  }
}
