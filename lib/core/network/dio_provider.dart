import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/in_memory_token.dart';
import '../storage/secure_token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  final secureStorage = SecureTokenStorage(const FlutterSecureStorage());

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final skipAuth = options.extra['skipAuth'] == true;
        if (skipAuth) {
          handler.next(options);
          return;
        }
        final token = ref.read(inMemoryAccessTokenProvider);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final skipRefresh = error.requestOptions.extra['skipRefresh'] == true;
        if (skipRefresh) {
          handler.next(error);
          return;
        }

        final statusCode = error.response?.statusCode;
        final is401 = statusCode == 401;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;

        if (is401 && !alreadyRetried) {
          final refreshed = await _refreshToken(ref, secureStorage);
          if (refreshed) {
            final req = error.requestOptions;
            req.extra['retried'] = true;
            final token = ref.read(inMemoryAccessTokenProvider);
            if (token != null && token.isNotEmpty) {
              req.headers['Authorization'] = 'Bearer $token';
            }
            final response = await dio.fetch(req);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

Future<bool> _refreshToken(Ref ref, SecureTokenStorage storage) async {
  final refreshToken = await storage.readRefreshToken();
  if (refreshToken == null || refreshToken.isEmpty) {
    ref.read(inMemoryAccessTokenProvider.notifier).state = null;
    await storage.clear();
    return false;
  }

  final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  try {
    final response = await refreshDio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final data = response.data as Map<String, dynamic>;
    final newAccess = (data['access_token'] ?? '') as String;
    final newRefresh = (data['refresh_token'] ?? '') as String;
    if (newAccess.isEmpty || newRefresh.isEmpty) {
      throw StateError('Tokens vacios');
    }

    ref.read(inMemoryAccessTokenProvider.notifier).state = newAccess;
    await storage.saveRefreshToken(newRefresh);
    return true;
  } catch (_) {
    ref.read(inMemoryAccessTokenProvider.notifier).state = null;
    await storage.clear();
    return false;
  }
}
