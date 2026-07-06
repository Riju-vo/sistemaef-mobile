import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/bitacora_models.dart';

abstract class BitacoraRepository {
  Future<Result<BitacoraListResponse>> listBitacora(BitacoraQuery query);
}

final bitacoraRepositoryProvider = Provider<BitacoraRepository>((ref) {
  return BitacoraRepositoryImpl(ref.read(dioProvider));
});

class BitacoraRepositoryImpl implements BitacoraRepository {
  final Dio _dio;

  BitacoraRepositoryImpl(this._dio);

  @override
  Future<Result<BitacoraListResponse>> listBitacora(BitacoraQuery query) async {
    try {
      final response = await _dio.get(
        '/bitacora',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        BitacoraListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar la bitacora'),
      );
    }
  }
}
