import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/clientes_repository.dart';
import '../domain/cliente_models.dart';

final clientesQueryProvider = StateProvider<ClientesQuery>((ref) {
  return const ClientesQuery();
});

final clientesListProvider = FutureProvider.autoDispose<ClientesListResponse>((
  ref,
) async {
  final query = ref.watch(clientesQueryProvider);
  final repository = ref.watch(clientesRepositoryProvider);
  final result = await repository.listClientes(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar clientes');
});
