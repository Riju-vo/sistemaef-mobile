import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pdvs_repository.dart';
import '../domain/pdv_models.dart';

final pdvsQueryProvider = StateProvider<PdvsQuery>((ref) {
  return const PdvsQuery();
});

final pdvsListProvider = FutureProvider.autoDispose<PdvsListResponse>((ref) async {
  final query = ref.watch(pdvsQueryProvider);
  final repository = ref.watch(pdvsRepositoryProvider);
  final result = await repository.listPdvs(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar PDVs');
});
