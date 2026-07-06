import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bitacora_repository.dart';
import '../domain/bitacora_models.dart';

final bitacoraQueryProvider = StateProvider<BitacoraQuery>((ref) {
  return const BitacoraQuery();
});

final bitacoraListProvider = FutureProvider.autoDispose<BitacoraListResponse>((ref) async {
  final query = ref.watch(bitacoraQueryProvider);
  final repository = ref.watch(bitacoraRepositoryProvider);
  final result = await repository.listBitacora(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar la bitacora');
});
