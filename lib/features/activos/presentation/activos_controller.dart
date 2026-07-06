import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/activos_repository.dart';
import '../domain/activo_models.dart';

final activosQueryProvider = StateProvider<ActivosQuery>((ref) {
  return const ActivosQuery();
});

final activosListProvider = FutureProvider.autoDispose<ActivosListResponse>((ref) async {
  final query = ref.watch(activosQueryProvider);
  final repository = ref.watch(activosRepositoryProvider);
  final result = await repository.listActivos(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar activos');
});

final activoContextoProvider = FutureProvider.autoDispose
    .family<ActivoContextoOperativo, String>((ref, activoId) async {
  final repository = ref.watch(activosRepositoryProvider);
  final result = await repository.getContextoOperativo(activoId);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar el activo');
});
