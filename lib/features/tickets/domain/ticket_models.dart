import '../../../shared/models/pagination_meta.dart';
import '../../../shared/models/tipo_rol.dart';

enum TicketEstado {
  pendienteAprobacion,
  aprobado,
  enAtencion,
  concluido,
  inconcluso,
  rechazado,
}

enum TicketResponsableTipo {
  tecnicoInterno,
  proveedor,
}

class TicketCandidato {
  final String idActivo;
  final String idAsignacionActivo;
  final String idCliente;
  final String? idPdv;
  final String etiqueta;
  final String serial;
  final String descripcionEquipo;
  final String estadoEquipo;
  final String nombreCliente;
  final String? nombrePdv;
  final String? direccion;
  final String? telefono;
  final String? direccionId;
  final String? canal;
  final String? supracanal;
  final bool bloqueadoPorTicketAbierto;
  final String? ticketAbiertoId;
  final TicketEstado? ticketAbiertoEstado;

  const TicketCandidato({
    required this.idActivo,
    required this.idAsignacionActivo,
    required this.idCliente,
    required this.idPdv,
    required this.etiqueta,
    required this.serial,
    required this.descripcionEquipo,
    required this.estadoEquipo,
    required this.nombreCliente,
    required this.nombrePdv,
    required this.direccion,
    required this.telefono,
    required this.direccionId,
    required this.canal,
    required this.supracanal,
    required this.bloqueadoPorTicketAbierto,
    required this.ticketAbiertoId,
    required this.ticketAbiertoEstado,
  });

  factory TicketCandidato.fromJson(Map<String, dynamic> json) {
    return TicketCandidato(
      idActivo: (json['id_activo'] ?? '').toString(),
      idAsignacionActivo: (json['id_asignacion_activo'] ?? '').toString(),
      idCliente: (json['id_cliente'] ?? '').toString(),
      idPdv: json['id_pdv']?.toString(),
      etiqueta: (json['etiqueta'] ?? '') as String,
      serial: (json['serial'] ?? '') as String,
      descripcionEquipo: (json['descripcion_equipo'] ?? '') as String,
      estadoEquipo: (json['estado_equipo'] ?? '') as String,
      nombreCliente: (json['nombre_cliente'] ?? '') as String,
      nombrePdv: json['nombre_pdv'] as String?,
      direccion: json['direccion'] as String?,
      telefono: json['telefono'] as String?,
      direccionId: json['direccion_id'] as String?,
      canal: json['canal'] as String?,
      supracanal: json['supracanal'] as String?,
      bloqueadoPorTicketAbierto:
          (json['bloqueado_por_ticket_abierto'] ?? false) as bool,
      ticketAbiertoId: json['ticket_abierto_id']?.toString(),
      ticketAbiertoEstado: ticketEstadoFromApiNullable(
        json['ticket_abierto_estado'] as String?,
      ),
    );
  }
}

class TicketUsuario {
  final String idUsuario;
  final String username;
  final String email;
  final TipoRol? tipoRol;

  const TicketUsuario({
    required this.idUsuario,
    required this.username,
    required this.email,
    required this.tipoRol,
  });

  factory TicketUsuario.fromJson(Map<String, dynamic> json) {
    return TicketUsuario(
      idUsuario: (json['id_usuario'] ?? '').toString(),
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      tipoRol: tipoRolFromInt(json['tipo_rol'] as int?),
    );
  }
}

class TicketActivo {
  final String idActivo;
  final String etiqueta;
  final String serial;
  final String descripcionEquipo;
  final String estadoEquipo;
  final String tipoActivo;

  const TicketActivo({
    required this.idActivo,
    required this.etiqueta,
    required this.serial,
    required this.descripcionEquipo,
    required this.estadoEquipo,
    required this.tipoActivo,
  });

  factory TicketActivo.fromJson(Map<String, dynamic> json) {
    return TicketActivo(
      idActivo: (json['id_activo'] ?? '').toString(),
      etiqueta: (json['etiqueta'] ?? '') as String,
      serial: (json['serial'] ?? '') as String,
      descripcionEquipo: (json['descripcion_equipo'] ?? '') as String,
      estadoEquipo: (json['estado_equipo'] ?? '') as String,
      tipoActivo: (json['tipo_activo'] ?? '') as String,
    );
  }
}

class TicketCliente {
  final String idCliente;
  final String codigoCliente;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final String? direccionId;

  const TicketCliente({
    required this.idCliente,
    required this.codigoCliente,
    required this.nombre,
    required this.telefono,
    required this.direccion,
    required this.direccionId,
  });

  factory TicketCliente.fromJson(Map<String, dynamic> json) {
    return TicketCliente(
      idCliente: (json['id_cliente'] ?? '').toString(),
      codigoCliente: (json['codigo_cliente'] ?? '').toString(),
      nombre: (json['nombre'] ?? '') as String,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
      direccionId: json['direccion_id'] as String?,
    );
  }
}

class TicketPdv {
  final String idPdv;
  final String nombreNegocio;
  final String? direccion;
  final String? direccionId;
  final String? nit;
  final String supracanal;
  final String canal;

  const TicketPdv({
    required this.idPdv,
    required this.nombreNegocio,
    required this.direccion,
    required this.direccionId,
    required this.nit,
    required this.supracanal,
    required this.canal,
  });

  factory TicketPdv.fromJson(Map<String, dynamic> json) {
    return TicketPdv(
      idPdv: (json['id_pdv'] ?? '').toString(),
      nombreNegocio: (json['nombre_negocio'] ?? '') as String,
      direccion: json['direccion'] as String?,
      direccionId: json['direccion_id'] as String?,
      nit: json['nit'] as String?,
      supracanal: (json['supracanal'] ?? '') as String,
      canal: (json['canal'] ?? '') as String,
    );
  }
}

class TicketItem {
  final String idTicket;
  final TicketEstado estado;
  final String tipoServicio;
  final bool emergencia;
  final String? comentarioRegistrador;
  final String? operadorPreasignado;
  final String? observacionAutorizador;
  final String fechaCreacion;
  final String? fechaDecision;
  final TicketResponsableTipo? tipoResponsableEjecucion;
  final String? fechaAsignacionEjecucion;
  final String? fechaInicioAtencion;
  final String? fechaCierre;
  final String? comentarioCierre;
  final String? evidenciaCierreUrl;
  final TicketActivo activo;
  final TicketCliente cliente;
  final TicketPdv? pdv;
  final TicketUsuario registrador;
  final TicketUsuario? autorizador;
  final TicketUsuario? responsableEjecucion;

  const TicketItem({
    required this.idTicket,
    required this.estado,
    required this.tipoServicio,
    required this.emergencia,
    required this.comentarioRegistrador,
    required this.operadorPreasignado,
    required this.observacionAutorizador,
    required this.fechaCreacion,
    required this.fechaDecision,
    required this.tipoResponsableEjecucion,
    required this.fechaAsignacionEjecucion,
    required this.fechaInicioAtencion,
    required this.fechaCierre,
    required this.comentarioCierre,
    required this.evidenciaCierreUrl,
    required this.activo,
    required this.cliente,
    required this.pdv,
    required this.registrador,
    required this.autorizador,
    required this.responsableEjecucion,
  });

  factory TicketItem.fromJson(Map<String, dynamic> json) {
    return TicketItem(
      idTicket: (json['id_ticket'] ?? '').toString(),
      estado: ticketEstadoFromApi(json['estado'] as String?),
      tipoServicio: (json['tipo_servicio'] ?? '') as String,
      emergencia: (json['emergencia'] ?? false) as bool,
      comentarioRegistrador: json['comentario_registrador'] as String?,
      operadorPreasignado: json['operador_preasignado'] as String?,
      observacionAutorizador: json['observacion_autorizador'] as String?,
      fechaCreacion: (json['fecha_creacion'] ?? '') as String,
      fechaDecision: json['fecha_decision'] as String?,
      tipoResponsableEjecucion: ticketResponsableTipoFromApi(
          json['tipo_responsable_ejecucion'] as String?),
      fechaAsignacionEjecucion: json['fecha_asignacion_ejecucion'] as String?,
      fechaInicioAtencion: json['fecha_inicio_atencion'] as String?,
      fechaCierre: json['fecha_cierre'] as String?,
      comentarioCierre: json['comentario_cierre'] as String?,
      evidenciaCierreUrl: json['evidencia_cierre_url'] as String?,
      activo: TicketActivo.fromJson(
          (json['activo'] as Map).cast<String, dynamic>()),
      cliente: TicketCliente.fromJson(
          (json['cliente'] as Map).cast<String, dynamic>()),
      pdv: json['pdv'] == null
          ? null
          : TicketPdv.fromJson((json['pdv'] as Map).cast<String, dynamic>()),
      registrador: TicketUsuario.fromJson(
          (json['registrador'] as Map).cast<String, dynamic>()),
      autorizador: json['autorizador'] == null
          ? null
          : TicketUsuario.fromJson(
              (json['autorizador'] as Map).cast<String, dynamic>()),
      responsableEjecucion: json['responsable_ejecucion'] == null
          ? null
          : TicketUsuario.fromJson(
              (json['responsable_ejecucion'] as Map).cast<String, dynamic>(),
            ),
    );
  }
}

class TicketsQuery {
  final int page;
  final int limit;
  final String search;
  final TicketEstado? estado;
  final String? tipoServicio;
  final bool? emergencia;
  final bool soloMios;

  const TicketsQuery({
    this.page = 1,
    this.limit = 20,
    this.search = '',
    this.estado,
    this.tipoServicio,
    this.emergencia,
    this.soloMios = false,
  });

  TicketsQuery copyWith({
    int? page,
    int? limit,
    String? search,
    TicketEstado? estado,
    String? tipoServicio,
    bool clearTipoServicio = false,
    bool? emergencia,
    bool clearEmergencia = false,
    bool clearEstado = false,
    bool? soloMios,
  }) {
    return TicketsQuery(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      estado: clearEstado ? null : (estado ?? this.estado),
      tipoServicio:
          clearTipoServicio ? null : (tipoServicio ?? this.tipoServicio),
      emergencia: clearEmergencia ? null : (emergencia ?? this.emergencia),
      soloMios: soloMios ?? this.soloMios,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    return {
      'page': page,
      'limit': limit,
      if (search.trim().isNotEmpty) 'search': search.trim(),
      if (estado != null) 'estado': ticketEstadoToApi(estado!),
      if (tipoServicio != null && tipoServicio!.trim().isNotEmpty)
        'tipo_servicio': tipoServicio,
      if (emergencia != null) 'emergencia': emergencia,
      if (soloMios) 'solo_mios': true,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is TicketsQuery &&
        other.page == page &&
        other.limit == limit &&
        other.search == search &&
        other.estado == estado &&
        other.tipoServicio == tipoServicio &&
        other.emergencia == emergencia &&
        other.soloMios == soloMios;
  }

  @override
  int get hashCode => Object.hash(
        page,
        limit,
        search,
        estado,
        tipoServicio,
        emergencia,
        soloMios,
      );
}

class TicketsListResponse {
  final List<TicketItem> data;
  final PaginationMeta meta;

  const TicketsListResponse({
    required this.data,
    required this.meta,
  });

  factory TicketsListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => TicketItem.fromJson(item.cast<String, dynamic>()))
        .toList();

    return TicketsListResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

class TicketCandidatosResponse {
  final List<TicketCandidato> data;
  final PaginationMeta meta;

  const TicketCandidatosResponse({
    required this.data,
    required this.meta,
  });

  factory TicketCandidatosResponse.fromJson(Map<String, dynamic> json) {
    final rawData = (json['data'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map>()
        .map((item) => TicketCandidato.fromJson(item.cast<String, dynamic>()))
        .toList();

    return TicketCandidatosResponse(
      data: rawData,
      meta: PaginationMeta.fromJson(
        ((json['meta'] as Map?) ?? <String, dynamic>{}).cast<String, dynamic>(),
      ),
    );
  }
}

TicketEstado ticketEstadoFromApi(String? value) {
  switch (value) {
    case 'APROBADO':
      return TicketEstado.aprobado;
    case 'EN_ATENCION':
      return TicketEstado.enAtencion;
    case 'CONCLUIDO':
      return TicketEstado.concluido;
    case 'INCONCLUSO':
      return TicketEstado.inconcluso;
    case 'RECHAZADO':
      return TicketEstado.rechazado;
    case 'PENDIENTE_APROBACION':
    default:
      return TicketEstado.pendienteAprobacion;
  }
}

TicketEstado? ticketEstadoFromApiNullable(String? value) {
  if (value == null || value.isEmpty) return null;
  return ticketEstadoFromApi(value);
}

String ticketEstadoToApi(TicketEstado value) {
  switch (value) {
    case TicketEstado.pendienteAprobacion:
      return 'PENDIENTE_APROBACION';
    case TicketEstado.aprobado:
      return 'APROBADO';
    case TicketEstado.enAtencion:
      return 'EN_ATENCION';
    case TicketEstado.concluido:
      return 'CONCLUIDO';
    case TicketEstado.inconcluso:
      return 'INCONCLUSO';
    case TicketEstado.rechazado:
      return 'RECHAZADO';
  }
}

String ticketEstadoLabel(TicketEstado value) {
  switch (value) {
    case TicketEstado.pendienteAprobacion:
      return 'Pendiente';
    case TicketEstado.aprobado:
      return 'Aprobado';
    case TicketEstado.enAtencion:
      return 'En atencion';
    case TicketEstado.concluido:
      return 'Concluido';
    case TicketEstado.inconcluso:
      return 'Inconcluso';
    case TicketEstado.rechazado:
      return 'Rechazado';
  }
}

TicketResponsableTipo? ticketResponsableTipoFromApi(String? value) {
  switch (value) {
    case 'TECNICO_INTERNO':
      return TicketResponsableTipo.tecnicoInterno;
    case 'PROVEEDOR':
      return TicketResponsableTipo.proveedor;
    default:
      return null;
  }
}

String formatTicketTipoServicio(String value) {
  if (value.isEmpty) return '-';
  return value.split('_').map((segment) {
    if (segment.isEmpty) return segment;
    final lower = segment.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }).join(' ');
}

String responsableTipoToApi(TicketResponsableTipo value) {
  switch (value) {
    case TicketResponsableTipo.tecnicoInterno:
      return 'TECNICO_INTERNO';
    case TicketResponsableTipo.proveedor:
      return 'PROVEEDOR';
  }
}

String responsableTipoLabel(TicketResponsableTipo value) {
  switch (value) {
    case TicketResponsableTipo.tecnicoInterno:
      return 'Tecnico interno';
    case TicketResponsableTipo.proveedor:
      return 'Proveedor';
  }
}

const List<String> activeTicketServiceOptions = [
  'DESCARTE',
  'DIAGNOSTICO',
  'ENTREGA_INSTALACION',
  'GARANTIA',
  'IMPRODUCTIVOS',
  'RETIRO',
  'RUTA_MANTTO',
  'TALLER_MANTTO_MAYOR',
];

const List<String> allTicketServiceOptions = [
  'ACTIVACION',
  'CONVERSION',
  'DESCARTE',
  'DIAGNOSTICO',
  'ENTREGA_INSTALACION',
  'GARANTIA',
  'IMPRODUCTIVOS',
  'MANTENIMIENTO_ESTRUCTURA',
  'RETIRO',
  'RUTA_MANTTO',
  'TALLER_MANTTO_MAYOR',
];
