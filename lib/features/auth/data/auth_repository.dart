import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/auth_models.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> login(String email, String password);
  Future<Result<AuthSession>> refresh(String refreshToken);
  Future<void> logout();
  Future<Result<Map<String, dynamic>>> me();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(dioProvider));
});

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  @override
  Future<Result<AuthSession>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(extra: {'skipAuth': true, 'skipRefresh': true}),
      );
      return Result.success(
        AuthSession.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No fue posible iniciar sesion'),
      );
    }
  }

  @override
  Future<Result<AuthSession>> refresh(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(extra: {'skipAuth': true, 'skipRefresh': true}),
      );
      return Result.success(
        AuthSession.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (error) {
      return Result.error(extractDioErrorMessage(error, 'Sesion expirada'));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
  }

  @override
  Future<Result<Map<String, dynamic>>> me() async {
    try {
      final response = await _dio.get('/auth/me');
      return Result.success((response.data as Map).cast<String, dynamic>());
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar /auth/me'),
      );
    }
  }
}
