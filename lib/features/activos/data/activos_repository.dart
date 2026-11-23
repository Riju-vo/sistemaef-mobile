import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/activo_models.dart';

abstract class ActivosRepository {
  Future<Result<ActivosListResponse>> listActivos(ActivosQuery query);
  Future<Result<ActivoContextoOperativo>> getContextoOperativo(String id);
  Future<Result<ActivoItem>> createActivo(ActivoUpsertPayload payload);
  Future<Result<ActivoItem>> updateActivo(
    String id,
    ActivoUpsertPayload payload,
  );
  Future<Result<ActivoItem>> changeEstadoActivo(
    String id,
    String estadoActivo,
  );
}

final activosRepositoryProvider = Provider<ActivosRepository>((ref) {
  return ActivosRepositoryImpl(ref.read(dioProvider));
});

class ActivosRepositoryImpl implements ActivosRepository {
  final Dio _dio;

  ActivosRepositoryImpl(this._dio);

  @override
  Future<Result<ActivosListResponse>> listActivos(ActivosQuery query) async {
    try {
      final response = await _dio.get(
        '/activos',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        ActivosListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar la lista de activos'),
      );
    }
  }

  @override
  Future<Result<ActivoContextoOperativo>> getContextoOperativo(String id) async {
    try {
      final response = await _dio.get('/activos/$id/contexto-operativo');
      return Result.success(
        ActivoContextoOperativo.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo cargar el contexto operativo del activo',
        ),
      );
    }
  }

  @override
  Future<Result<ActivoItem>> createActivo(ActivoUpsertPayload payload) async {
    try {
      final response = await _dio.post('/activos', data: payload.toJson());
      return Result.success(
        ActivoItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el activo'),
      );
    }
  }

  @override
  Future<Result<ActivoItem>> updateActivo(
    String id,
    ActivoUpsertPayload payload,
  ) async {
    try {
      final response = await _dio.patch('/activos/$id', data: payload.toJson());
      return Result.success(
        ActivoItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo actualizar el activo'),
      );
    }
  }

  @override
  Future<Result<ActivoItem>> changeEstadoActivo(
    String id,
    String estadoActivo,
  ) async {
    try {
      final response = await _dio.patch(
        '/activos/$id/estado',
        data: {'estado_activo': estadoActivo},
      );
      return Result.success(
        ActivoItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo cambiar el estado del activo',
        ),
      );
    }
  }
}
