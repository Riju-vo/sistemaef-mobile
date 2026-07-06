import 'dart:typed_data';

import '../../../shared/models/pagination_meta.dart';

enum CategoriaSofia { a, b, c }

CategoriaSofia? categoriaSofiaFromApiNullable(String? value) {
  switch ((value ?? '').trim().toUpperCase()) {
    case 'A':
      return CategoriaSofia.a;
    case 'B':
      return CategoriaSofia.b;
    case 'C':
      return CategoriaSofia.c;
    default:
      return null;
  }
}

String categoriaSofiaToApi(CategoriaSofia value) {
  switch (value) {
    case CategoriaSofia.a:
      return 'A';
    case CategoriaSofia.b:
      return 'B';
    case CategoriaSofia.c:
      return 'C';
  }
}

class ClienteItem {
  final String idCliente;
  final String codigoCliente;
  final String nombre;
  final String? telefono;
  final CategoriaSofia? categoriaSofia;
  final String? direccion;
  final String? direccionId;
  final double? latitud;
  final double? longitud;
  final bool activo;

  const ClienteItem({
    required this.idCliente,
    required this.codigoCliente,
    required this.nombre,
    required this.telefono,
    required this.categoriaSofia,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.activo,
  });

  factory ClienteItem.fromJson(Map<String, dynamic> json) {
    return ClienteItem(
      idCliente: (json['id_cliente'] ?? '').toString(),
      codigoCliente: (json['codigo_cliente'] ?? '').toString(),
      nombre: (json['nombre'] ?? '') as String,
      telefono: json['telefono'] as String?,
      categoriaSofia: categoriaSofiaFromApiNullable(
        json['categoria_sofia'] as String?,
      ),
      direccion: json['direccion'] as String?,
      direccionId: json['direccion_id'] as String?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      activo: (json['activo'] ?? false) as bool,
    );
  }
}

class ClientesQuery {
  final int page;
  final int limit;
  final String nombre;
  final String codigoCliente;
  final bool? activo;
  final CategoriaSofia? categoriaSofia;

  const ClientesQuery({
    this.page = 1,
    this.limit = 20,
    this.nombre = '',
    this.codigoCliente = '',
    this.activo,
    this.categoriaSofia,
  });

  ClientesQuery copyWith({
    int? page,
    int? limit,
    String? nombre,
    String? codigoCliente,
    bool? activo,
    bool clearActivo = false,
    CategoriaSofia? categoriaSofia,
    bool clearCategoriaSofia = false,
  }) {
    return ClientesQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      nombre: nombre ?? this.nombre,
      codigoCliente: codigoCliente ?? this.codigoCliente,
      activo: clearActivo ? null : (activo ?? this.activo),
      categoriaSofia: clearCategoriaSofia
          ? null
          : (categoriaSofia ?? this.categoriaSofia),
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (nombre.trim().isNotEmpty) 'nombre': nombre.trim(),
      if (codigoCliente.trim().isNotEmpty)
        'codigo_cliente': codigoCliente.trim(),
      if (activo != null) 'activo': activo,
      if (categoriaSofia != null)
        'categoria_sofia': categoriaSofiaToApi(categoriaSofia!),
    };
  }
}

class ClientesListResponse {
  final List<ClienteItem> data;
  final PaginationMeta meta;

  const ClientesListResponse({
    required this.data,
    required this.meta,
  });

  factory ClientesListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => ClienteItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return ClientesListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

class ClienteUpsertPayload {
  final String codigoCliente;
  final String nombre;
  final String? telefono;
  final CategoriaSofia categoriaSofia;
  final String? direccion;
  final String? direccionId;
  final double? latitud;
  final double? longitud;
  final bool activo;

  const ClienteUpsertPayload({
    required this.codigoCliente,
    required this.nombre,
    required this.telefono,
    required this.categoriaSofia,
    required this.direccion,
    required this.direccionId,
    required this.latitud,
    required this.longitud,
    required this.activo,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo_cliente': codigoCliente.trim(),
      'nombre': nombre.trim(),
      if ((telefono ?? '').trim().isNotEmpty) 'telefono': telefono!.trim(),
      'categoria_sofia': categoriaSofiaToApi(categoriaSofia),
      if ((direccion ?? '').trim().isNotEmpty) 'direccion': direccion!.trim(),
      if ((direccionId ?? '').trim().isNotEmpty)
        'direccion_id': direccionId!.trim(),
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      'activo': activo,
    };
  }
}

class ImportJobError {
  final int linea;
  final String error;
  final String? fila;

  const ImportJobError({
    required this.linea,
    required this.error,
    required this.fila,
  });

  factory ImportJobError.fromJson(Map<String, dynamic> json) {
    return ImportJobError(
      linea: (json['linea'] ?? 0) as int,
      error: (json['error'] ?? '') as String,
      fila: json['fila'] as String?,
    );
  }
}

class ClienteImportJob {
  final String idJob;
  final String nombreArchivo;
  final String estado;
  final int filasTotales;
  final int filasProcesadas;
  final int creados;
  final int actualizados;
  final List<ImportJobError> errores;
  final String? fechaInicio;
  final String? fechaFin;

  const ClienteImportJob({
    required this.idJob,
    required this.nombreArchivo,
    required this.estado,
    required this.filasTotales,
    required this.filasProcesadas,
    required this.creados,
    required this.actualizados,
    required this.errores,
    required this.fechaInicio,
    required this.fechaFin,
  });

  bool get isFinished => estado == 'COMPLETADO' || estado == 'FALLIDO';

  int get progressPercent {
    if (filasTotales <= 0) {
      return estado == 'COMPLETADO' ? 100 : 0;
    }
    return ((filasProcesadas / filasTotales) * 100).round().clamp(0, 100);
  }

  factory ClienteImportJob.fromJson(Map<String, dynamic> json) {
    final rawErrors = (json['errores'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => ImportJobError.fromJson(item.cast<String, dynamic>()))
        .toList();

    return ClienteImportJob(
      idJob: (json['id_job'] ?? '').toString(),
      nombreArchivo: (json['nombre_archivo'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,
      filasTotales: (json['filas_totales'] ?? 0) as int,
      filasProcesadas: (json['filas_procesadas'] ?? 0) as int,
      creados: (json['creados'] ?? 0) as int,
      actualizados: (json['actualizados'] ?? 0) as int,
      errores: rawErrors,
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
    );
  }
}

class CsvUploadPayload {
  final Uint8List bytes;
  final String filename;

  const CsvUploadPayload({
    required this.bytes,
    required this.filename,
  });
}
