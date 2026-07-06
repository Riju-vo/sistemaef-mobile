import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/usuario_models.dart';

abstract class UsuariosRepository {
  Future<Result<UsuariosListResponse>> listUsuarios(UsuariosQuery query);
  Future<Result<UsuarioItem>> createUsuario(UsuarioCreatePayload payload);
  Future<Result<UsuarioItem>> updateUsuario(
    String id,
    UsuarioUpdatePayload payload,
  );
  Future<Result<UsuarioItem>> removeUsuario(String id);
  Future<Result<List<RolOption>>> listRoles();
}

final usuariosRepositoryProvider = Provider<UsuariosRepository>((ref) {
  return UsuariosRepositoryImpl(ref.read(dioProvider));
});

class UsuariosRepositoryImpl implements UsuariosRepository {
  final Dio _dio;

  UsuariosRepositoryImpl(this._dio);

  @override
  Future<Result<UsuariosListResponse>> listUsuarios(UsuariosQuery query) async {
    try {
      final response = await _dio.get(
        '/usuarios',
        queryParameters: query.toQueryParameters(),
      );
      return Result.success(
        UsuariosListResponse.fromJson(
          (response.data as Map).cast<String, dynamic>(),
        ),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar la lista de usuarios'),
      );
    }
  }

  @override
  Future<Result<UsuarioItem>> createUsuario(UsuarioCreatePayload payload) async {
    try {
      final response = await _dio.post('/usuarios', data: payload.toJson());
      return Result.success(
        UsuarioItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el usuario'),
      );
    }
  }

  @override
  Future<Result<UsuarioItem>> updateUsuario(
    String id,
    UsuarioUpdatePayload payload,
  ) async {
    try {
      final response = await _dio.patch('/usuarios/$id', data: payload.toJson());
      return Result.success(
        UsuarioItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo actualizar el usuario'),
      );
    }
  }

  @override
  Future<Result<UsuarioItem>> removeUsuario(String id) async {
    try {
      final response = await _dio.delete('/usuarios/$id');
      return Result.success(
        UsuarioItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo desactivar el usuario'),
      );
    }
  }

  @override
  Future<Result<List<RolOption>>> listRoles() async {
    try {
      final response = await _dio.get('/catalogos/roles');
      final data = response.data as List<dynamic>? ?? <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => RolOption.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar roles'),
      );
    }
  }
}
