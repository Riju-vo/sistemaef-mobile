import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalogos_repository.dart';
import '../domain/catalogo_models.dart';

final activeCatalogProvider = StateProvider<CatalogRoute>((ref) {
  return CatalogRoute.tiposActivo;
});

final catalogItemsProvider = FutureProvider.autoDispose<List<CatalogItem>>((ref) async {
  final route = ref.watch(activeCatalogProvider);
  final repository = ref.watch(catalogosRepositoryProvider);
  final result = await repository.listCatalog(route);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar el catalogo');
});
