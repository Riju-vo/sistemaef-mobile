import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../../activos/domain/activo_models.dart' show ActivoItem;
import '../domain/asignacion_models.dart';

abstract class AsignacionesRepository {
  Future<Result<AsignacionesListResponse>> listAsignaciones(
    AsignacionesQuery query,
  );
  Future<Result<AsignacionItem>> createAsignacion({
    required String idActivo,
    required String idCliente,
    String? idPdv,
    String? fechaInicio,
    String? estado,
    String? observacion,
  });
  Future<Result<AsignacionItem>> finalizarAsignacion({
    required String id,
    required int idEstadoActivo,
    String? fechaFin,
    String? estado,
    String? observacion,
  });
  Future<Result<List<ActivoItem>>> listActivosDisponibles();
  Future<Result<List<ClienteOption>>> listClientesActivos();
  Future<Result<List<PdvOption>>> listPdvsActivos();
  Future<Result<List<CatalogOption>>> listEstadosActivo();
}

final asignacionesRepositoryProvider = Provider<AsignacionesRepository>((ref) {
  return AsignacionesRepositoryImpl(ref.read(dioProvider));
});

class AsignacionesRepositoryImpl implements AsignacionesRepository {
  final Dio _dio;

  AsignacionesRepositoryImpl(this._dio);

  @override
  Future<Result<AsignacionesListResponse>> listAsignaciones(
    AsignacionesQuery query,
  ) async {
    try {
      final response = await _dio.get(
        '/asignaciones',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        AsignacionesListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo cargar la lista de asignaciones',
        ),
      );
    }
  }

  @override
  Future<Result<AsignacionItem>> createAsignacion({
    required String idActivo,
    required String idCliente,
    String? idPdv,
    String? fechaInicio,
    String? estado,
    String? observacion,
  }) async {
    try {
      final response = await _dio.post(
        '/asignaciones',
        data: {
          'id_activo': idActivo,
          'id_cliente': idCliente,
          if (idPdv != null && idPdv.trim().isNotEmpty) 'id_pdv': idPdv.trim(),
          if (fechaInicio != null && fechaInicio.trim().isNotEmpty)
            'fecha_inicio': fechaInicio.trim(),
          if (estado != null && estado.trim().isNotEmpty) 'estado': estado.trim(),
          if (observacion != null && observacion.trim().isNotEmpty)
            'observacion': observacion.trim(),
        },
      );
      return Result.success(
        AsignacionItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear la asignacion'),
      );
    }
  }

  @override
  Future<Result<AsignacionItem>> finalizarAsignacion({
    required String id,
    required int idEstadoActivo,
    String? fechaFin,
    String? estado,
    String? observacion,
  }) async {
    try {
      final response = await _dio.patch(
        '/asignaciones/$id/finalizar',
        data: {
          'id_estado_activo': idEstadoActivo,
          if (fechaFin != null && fechaFin.trim().isNotEmpty)
            'fecha_fin': fechaFin.trim(),
          if (estado != null && estado.trim().isNotEmpty) 'estado': estado.trim(),
          if (observacion != null && observacion.trim().isNotEmpty)
            'observacion': observacion.trim(),
        },
      );
      return Result.success(
        AsignacionItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo finalizar la asignacion'),
      );
    }
  }

  @override
  Future<Result<List<ActivoItem>>> listActivosDisponibles() async {
    try {
      final response = await _dio.get(
        '/activos',
        queryParameters: {'page': 1, 'limit': 100, 'activo': true},
      );
      final data =
          ((response.data as Map).cast<String, dynamic>())['data'] as List<dynamic>? ??
              <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => ActivoItem.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar activos'),
      );
    }
  }

  @override
  Future<Result<List<ClienteOption>>> listClientesActivos() async {
    try {
      final response = await _dio.get(
        '/clientes',
        queryParameters: {'page': 1, 'limit': 100, 'activo': true},
      );
      final data =
          ((response.data as Map).cast<String, dynamic>())['data'] as List<dynamic>? ??
              <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => ClienteOption.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar clientes'),
      );
    }
  }

  @override
  Future<Result<List<PdvOption>>> listPdvsActivos() async {
    try {
      final response = await _dio.get(
        '/pdvs',
        queryParameters: {'page': 1, 'limit': 200, 'activo': true},
      );
      final data =
          ((response.data as Map).cast<String, dynamic>())['data'] as List<dynamic>? ??
              <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => PdvOption.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar PDVs'),
      );
    }
  }

  @override
  Future<Result<List<CatalogOption>>> listEstadosActivo() async {
    try {
      final response = await _dio.get('/catalogos/estados-activo');
      final data = response.data as List<dynamic>? ?? <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => CatalogOption.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar estados de activo'),
      );
    }
  }
}
