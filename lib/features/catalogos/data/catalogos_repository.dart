import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/catalogo_models.dart';

abstract class CatalogosRepository {
  Future<Result<List<CatalogItem>>> listCatalog(CatalogRoute route);
  Future<Result<CatalogItem>> createCatalogItem(
    CatalogRoute route,
    String nombre,
  );
  Future<Result<CatalogItem>> updateCatalogItem(
    CatalogRoute route,
    int id,
    String nombre,
  );
}

final catalogosRepositoryProvider = Provider<CatalogosRepository>((ref) {
  return CatalogosRepositoryImpl(ref.read(dioProvider));
});

class CatalogosRepositoryImpl implements CatalogosRepository {
  final Dio _dio;

  CatalogosRepositoryImpl(this._dio);

  @override
  Future<Result<List<CatalogItem>>> listCatalog(CatalogRoute route) async {
    try {
      final response = await _dio.get('/catalogos/${catalogRoutePath(route)}');
      final data = response.data as List<dynamic>? ?? <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => CatalogItem.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar el catalogo'),
      );
    }
  }

  @override
  Future<Result<CatalogItem>> createCatalogItem(
    CatalogRoute route,
    String nombre,
  ) async {
    try {
      final response = await _dio.post(
        '/catalogos/${catalogRoutePath(route)}',
        data: {'nombre': nombre.trim()},
      );
      return Result.success(
        CatalogItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el item de catalogo'),
      );
    }
  }

  @override
  Future<Result<CatalogItem>> updateCatalogItem(
    CatalogRoute route,
    int id,
    String nombre,
  ) async {
    try {
      final response = await _dio.patch(
        '/catalogos/${catalogRoutePath(route)}/$id',
        data: {'nombre': nombre.trim()},
      );
      return Result.success(
        CatalogItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(
          error,
          'No se pudo actualizar el item de catalogo',
        ),
      );
    }
  }
}
