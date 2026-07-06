import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/asignaciones_repository.dart';
import '../domain/asignacion_models.dart';

final asignacionesQueryProvider = StateProvider<AsignacionesQuery>((ref) {
  return const AsignacionesQuery();
});

final asignacionesListProvider =
    FutureProvider.autoDispose<AsignacionesListResponse>((ref) async {
  final query = ref.watch(asignacionesQueryProvider);
  final repository = ref.watch(asignacionesRepositoryProvider);
  final result = await repository.listAsignaciones(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar asignaciones');
});
