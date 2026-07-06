import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/ticket_models.dart';

abstract class TicketsRepository {
  Future<Result<TicketsListResponse>> listTickets(TicketsQuery query);
  Future<Result<TicketCandidatosResponse>> listCandidatos({
    String search,
    bool soloDisponibles,
    int page,
    int limit,
  });
  Future<Result<TicketItem>> createTicket({
    required String idActivo,
    required String tipoServicio,
    required bool emergencia,
    required String comentarioRegistrador,
  });
  Future<Result<List<TicketUsuario>>> listResponsables(
    TicketResponsableTipo tipoResponsable,
  );
  Future<Result<TicketItem>> decidirTicket({
    required String id,
    required String decision,
    required String observacionAutorizador,
    TicketResponsableTipo? tipoResponsable,
    String? idResponsableEjecucion,
  });
  Future<Result<TicketItem>> getTicket(String id);
  Future<Result<TicketItem>> iniciarAtencion(String id);
  Future<Result<TicketItem>> cerrarTicket({
    required String id,
    required String resultado,
    required String evidenciaCierrePath,
    String? comentarioCierre,
  });
}

final ticketsRepositoryProvider = Provider<TicketsRepository>((ref) {
  return TicketsRepositoryImpl(ref.read(dioProvider));
});

class TicketsRepositoryImpl implements TicketsRepository {
  final Dio _dio;

  TicketsRepositoryImpl(this._dio);

  @override
  Future<Result<TicketsListResponse>> listTickets(TicketsQuery query) async {
    try {
      final response = await _dio.get(
        '/tickets',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        TicketsListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar la lista de tickets'),
      );
    }
  }

  @override
  Future<Result<TicketCandidatosResponse>> listCandidatos({
    String search = '',
    bool soloDisponibles = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/tickets/candidatos',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.trim().isNotEmpty) 'search': search.trim(),
          'solo_disponibles': soloDisponibles,
        },
      );
      return Result.success(
        TicketCandidatosResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo cargar los candidatos para ticket',
        ),
      );
    }
  }

  @override
  Future<Result<TicketItem>> createTicket({
    required String idActivo,
    required String tipoServicio,
    required bool emergencia,
    required String comentarioRegistrador,
  }) async {
    try {
      final response = await _dio.post(
        '/tickets',
        data: {
          'id_activo': idActivo,
          'tipo_servicio': tipoServicio,
          'emergencia': emergencia,
          'comentario_registrador': comentarioRegistrador.trim(),
        },
      );
      return Result.success(
        TicketItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el ticket'),
      );
    }
  }

  @override
  Future<Result<List<TicketUsuario>>> listResponsables(
    TicketResponsableTipo tipoResponsable,
  ) async {
    try {
      final response = await _dio.get(
        '/tickets/responsables',
        queryParameters: {
          'tipo_responsable': responsableTipoToApi(tipoResponsable),
        },
      );

      final data = ((response.data as Map).cast<String, dynamic>())['data']
              as List<dynamic>? ??
          <dynamic>[];

      return Result.success(
        data
            .cast<Map>()
            .map((item) => TicketUsuario.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo cargar responsables disponibles',
        ),
      );
    }
  }

  @override
  Future<Result<TicketItem>> decidirTicket({
    required String id,
    required String decision,
    required String observacionAutorizador,
    TicketResponsableTipo? tipoResponsable,
    String? idResponsableEjecucion,
  }) async {
    try {
      final response = await _dio.patch(
        '/tickets/$id/decision',
        data: {
          'decision': decision,
          'observacion_autorizador': observacionAutorizador.trim(),
          if (tipoResponsable != null)
            'tipo_responsable_ejecucion': responsableTipoToApi(tipoResponsable),
          if (idResponsableEjecucion != null &&
              idResponsableEjecucion.trim().isNotEmpty)
            'id_responsable_ejecucion': idResponsableEjecucion.trim(),
        },
      );
      return Result.success(
        TicketItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo decidir el ticket'),
      );
    }
  }

  @override
  Future<Result<TicketItem>> getTicket(String id) async {
    try {
      final response = await _dio.get('/tickets/$id');
      return Result.success(
        TicketItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
            error, 'No se pudo cargar el detalle del ticket'),
      );
    }
  }

  @override
  Future<Result<TicketItem>> iniciarAtencion(String id) async {
    try {
      final response =
          await _dio.patch('/tickets/$id/iniciar-atencion', data: {});
      return Result.success(
        TicketItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo iniciar la atencion del ticket',
        ),
      );
    }
  }

  @override
  Future<Result<TicketItem>> cerrarTicket({
    required String id,
    required String resultado,
    required String evidenciaCierrePath,
    String? comentarioCierre,
  }) async {
    try {
      final response = await _dio.patch(
        '/tickets/$id/cerrar',
        data: FormData.fromMap({
          'resultado': resultado,
          'evidencia_cierre': await MultipartFile.fromFile(
            evidenciaCierrePath,
            filename: evidenciaCierrePath.split(RegExp(r'[\\/]')).last,
          ),
          if (comentarioCierre != null && comentarioCierre.trim().isNotEmpty)
            'comentario_cierre': comentarioCierre.trim(),
        }),
      );
      return Result.success(
        TicketItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cerrar el ticket'),
      );
    }
  }
}
