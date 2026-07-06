import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_provider.dart';

final moduleApiProvider = Provider<ModuleApi>((ref) {
  return ModuleApi(ref.read(dioProvider));
});

class ModuleApi {
  final Dio _dio;
  ModuleApi(this._dio);

  Future<List<Map<String, dynamic>>> list(
    String path, {
    Map<String, dynamic> query = const {'page': 1, 'limit': 20},
  }) async {
    final res = await _dio.get(path, queryParameters: query);
    return _extractList(res.data);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _dio.get(path);
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<int> total(
    String path, {
    Map<String, dynamic> query = const {'page': 1, 'limit': 1},
  }) async {
    final res = await _dio.get(path, queryParameters: query);
    final data = res.data;

    if (data is Map<String, dynamic>) {
      final meta = data['meta'];
      if (meta is Map && meta['total'] is num) {
        return (meta['total'] as num).toInt();
      }

      final list = _extractList(data);
      return list.length;
    }

    final list = _extractList(data);
    return list.length;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .cast<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final rawList = data['data'];
      if (rawList is List) {
        return rawList
            .cast<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    }

    return <Map<String, dynamic>>[];
  }
}
