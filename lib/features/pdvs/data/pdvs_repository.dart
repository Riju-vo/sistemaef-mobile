import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/dio_error_message.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/dio_provider.dart';
import '../../clientes/domain/cliente_models.dart';
import '../domain/pdv_models.dart';

abstract class PdvsRepository {
  Future<Result<PdvsListResponse>> listPdvs(PdvsQuery query);
  Future<Result<PdvItem>> createPdv(PdvUpsertPayload payload);
  Future<Result<PdvItem>> createPdvConCliente({
    required PdvUpsertPayload pdv,
    required ClienteNuevoPayload? clienteNuevo,
  });
  Future<Result<PdvItem>> updatePdv(String id, PdvUpsertPayload payload);
  Future<Result<PdvItem>> removePdv(String id);
  Future<Result<List<ClienteItem>>> listClientesActivos();
  Future<Result<List<TipoCanalOption>>> listTiposCanal();
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
  Future<Result<PdvItem>> createPdvConCliente({
    required PdvUpsertPayload pdv,
    required ClienteNuevoPayload? clienteNuevo,
  }) async {
    try {
      final response = await _dio.post(
        '/pdvs/con-cliente',
        data: {
          'cliente': clienteNuevo?.toJson() ??
              {
                'modo': 'existente',
                'id_cliente': pdv.idCliente.trim(),
              },
          'pdv': {
            'nombre_negocio': pdv.nombreNegocio.trim(),
            if ((pdv.direccion ?? '').trim().isNotEmpty)
              'direccion': pdv.direccion!.trim(),
            if ((pdv.direccionId ?? '').trim().isNotEmpty)
              'direccion_id': pdv.direccionId!.trim(),
            if (pdv.latitud != null) 'latitud': pdv.latitud,
            if (pdv.longitud != null) 'longitud': pdv.longitud,
            if ((pdv.nit ?? '').trim().isNotEmpty) 'nit': pdv.nit!.trim(),
            'id_tipo_canal': pdv.idTipoCanal,
            'supracanal': supracanalToApi(pdv.supracanal),
          },
        },
      );
      return Result.success(
        PdvItem.fromJson((response.data as Map).cast<String, dynamic>()),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo crear el PDV con cliente'),
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

  @override
  Future<Result<List<ClienteItem>>> listClientesActivos() async {
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
            .map((item) => ClienteItem.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar clientes activos'),
      );
    }
  }

  @override
  Future<Result<List<TipoCanalOption>>> listTiposCanal() async {
    try {
      final response = await _dio.get('/catalogos/tipos-canal');
      final data = response.data as List<dynamic>? ?? <dynamic>[];
      return Result.success(
        data
            .cast<Map>()
            .map((item) => TipoCanalOption.fromJson(item.cast<String, dynamic>()))
            .toList(),
      );
    } catch (error) {
      return Result.error(
        extractDioErrorMessage(error, 'No se pudo cargar tipos de canal'),
      );
    }
  }
}
