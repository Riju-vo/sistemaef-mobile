import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/cliente_models.dart';

abstract class ClientesRepository {
  Future<Result<ClientesListResponse>> listClientes(ClientesQuery query);
  Future<Result<ClienteItem>> createCliente(ClienteUpsertPayload payload);
  Future<Result<ClienteItem>> updateCliente(
    String id,
    ClienteUpsertPayload payload,
  );
  Future<Result<ClienteItem>> removeCliente(String id);
}

final clientesRepositoryProvider = Provider<ClientesRepository>((ref) {
  return ClientesRepositoryImpl(ref.read(dioProvider));
});

class ClientesRepositoryImpl implements ClientesRepository {
  final Dio _dio;

  ClientesRepositoryImpl(this._dio);

  @override
  Future<Result<ClientesListResponse>> listClientes(ClientesQuery query) async {
    try {
      final response = await _dio.get(
        '/clientes',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        ClientesListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar la lista de clientes'),
      );
    }
  }

  @override
  Future<Result<ClienteItem>> createCliente(ClienteUpsertPayload payload) async {
    try {
      final response = await _dio.post('/clientes', data: payload.toJson());
      return Result.success(
        ClienteItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el cliente'),
      );
    }
  }

  @override
  Future<Result<ClienteItem>> updateCliente(
    String id,
    ClienteUpsertPayload payload,
  ) async {
    try {
      final response = await _dio.patch('/clientes/$id', data: payload.toJson());
      return Result.success(
        ClienteItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo actualizar el cliente'),
      );
    }
  }

  @override
  Future<Result<ClienteItem>> removeCliente(String id) async {
    try {
      final response = await _dio.delete('/clientes/$id');
      return Result.success(
        ClienteItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo desactivar el cliente'),
      );
    }
  }

}
