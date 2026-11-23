import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/pdv_models.dart';

abstract class PdvsRepository {
  Future<Result<PdvsListResponse>> listPdvs(PdvsQuery query);
  Future<Result<PdvItem>> createPdv(PdvUpsertPayload payload);
  Future<Result<PdvItem>> updatePdv(String id, PdvUpsertPayload payload);
  Future<Result<PdvItem>> removePdv(String id);
}

final pdvsRepositoryProvider = Provider<PdvsRepository>((ref) {
  return PdvsRepositoryImpl(ref.read(dioProvider));
});

class PdvsRepositoryImpl implements PdvsRepository {
  final Dio _dio;

  PdvsRepositoryImpl(this._dio);

  @override
  Future<Result<PdvsListResponse>> listPdvs(PdvsQuery query) async {
    try {
      final response = await _dio.get(
        '/pdvs',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        PdvsListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar la lista de PDVs'),
      );
    }
  }

  @override
  Future<Result<PdvItem>> createPdv(PdvUpsertPayload payload) async {
    try {
      final response = await _dio.post('/pdvs', data: payload.toJson());
      return Result.success(
        PdvItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el PDV'),
      );
    }
  }

  @override
  Future<Result<PdvItem>> updatePdv(String id, PdvUpsertPayload payload) async {
    try {
      final response = await _dio.patch('/pdvs/$id', data: payload.toJson());
      return Result.success(
        PdvItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo actualizar el PDV'),
      );
    }
  }

  @override
  Future<Result<PdvItem>> removePdv(String id) async {
    try {
      final response = await _dio.delete('/pdvs/$id');
      return Result.success(
        PdvItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo desactivar el PDV'),
      );
    }
  }
}
