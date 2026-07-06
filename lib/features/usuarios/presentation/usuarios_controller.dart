import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/usuarios_repository.dart';
import '../domain/usuario_models.dart';

final usuariosQueryProvider = StateProvider<UsuariosQuery>((ref) {
  return const UsuariosQuery();
});

final usuariosListProvider = FutureProvider.autoDispose<UsuariosListResponse>((ref) async {
  final query = ref.watch(usuariosQueryProvider);
  final repository = ref.watch(usuariosRepositoryProvider);
  final result = await repository.listUsuarios(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar usuarios');
});
