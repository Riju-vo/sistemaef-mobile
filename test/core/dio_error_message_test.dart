import 'package:dio/dio.dart';
import 'package:sistemaef_mobile/core/errors/dio_error_message.dart';
import 'package:test/test.dart';

void main() {
  group('extractDioErrorMessage', () {
    test('uses backend string message when available', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/clientes'),
        response: Response(
          requestOptions: RequestOptions(path: '/clientes'),
          data: {'message': 'Ya existe un cliente con ese codigo_cliente'},
        ),
      );

      final message = extractDioErrorMessage(error, 'fallback');

      expect(message, 'Ya existe un cliente con ese codigo_cliente');
    });

    test('joins backend validation messages when message is a list', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/pdvs'),
        response: Response(
          requestOptions: RequestOptions(path: '/pdvs'),
          data: {
            'message': ['nombre requerido', 'id_tipo_canal invalido'],
          },
        ),
      );

      final message = extractDioErrorMessage(error, 'fallback');

      expect(message, 'nombre requerido, id_tipo_canal invalido');
    });

    test('falls back to default message when nothing useful exists', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/tickets'),
      );

      final message = extractDioErrorMessage(error, 'No se pudo cargar');

      expect(message, 'No se pudo cargar');
    });
  });
}
