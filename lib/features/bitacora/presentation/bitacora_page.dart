import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../domain/bitacora_models.dart';
import 'bitacora_controller.dart';

class BitacoraPage extends ConsumerStatefulWidget {
  const BitacoraPage({super.key});

  @override
  ConsumerState<BitacoraPage> createState() => _BitacoraPageState();
}

class _BitacoraPageState extends ConsumerState<BitacoraPage> {
  late final TextEditingController _accionCtrl;
  late final TextEditingController _entidadCtrl;
  late final TextEditingController _entidadIdCtrl;
  late final TextEditingController _usuarioIdCtrl;
  late final TextEditingController _fechaDesdeCtrl;
  late final TextEditingController _fechaHastaCtrl;

  @override
  void initState() {
    super.initState();
    _accionCtrl = TextEditingController();
    _entidadCtrl = TextEditingController();
    _entidadIdCtrl = TextEditingController();
    _usuarioIdCtrl = TextEditingController();
    _fechaDesdeCtrl = TextEditingController();
    _fechaHastaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _accionCtrl.dispose();
    _entidadCtrl.dispose();
    _entidadIdCtrl.dispose();
    _usuarioIdCtrl.dispose();
    _fechaDesdeCtrl.dispose();
    _fechaHastaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final canView = auth.user?.rol == TipoRol.autorizador ||
        auth.user?.rol == TipoRol.administrador;

    if (!canView) {
      return const Column(
        children: [
          PageHeader(
            title: 'Bitacora',
            subtitle: 'Trazabilidad de eventos operativos del sistema',
          ),
          DataCard(
            child: Text(
              'Este modulo esta disponible para Autorizador y Administrador.',
            ),
          ),
        ],
      );
    }

    final query = ref.watch(bitacoraQueryProvider);
    final bitacoraAsync = ref.watch(bitacoraListProvider);

    return Column(
      children: [
        PageHeader(
          title: 'Bitacora',
          subtitle: 'Historial de actividad y auditoria operativa',
          action: IconButton(
            onPressed: () => ref.refresh(bitacoraListProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ),
        DataCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _accionCtrl,
                      decoration: const InputDecoration(labelText: 'Accion'),
                      onSubmitted: (value) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: 1, accion: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _entidadCtrl,
                      decoration: const InputDecoration(labelText: 'Entidad'),
                      onSubmitted: (value) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: 1, entidad: value.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _entidadIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Entidad ID'),
                      onSubmitted: (value) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: 1, entidadId: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _usuarioIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Usuario ID'),
                      onSubmitted: (value) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: 1, idUsuario: value.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fechaDesdeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Fecha desde (YYYY-MM-DD)',
                      ),
                      onSubmitted: (value) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: 1, fechaDesde: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _fechaHastaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Fecha hasta (YYYY-MM-DD)',
                      ),
                      onSubmitted: (value) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: 1, fechaHasta: value.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _accionCtrl.clear();
                    _entidadCtrl.clear();
                    _entidadIdCtrl.clear();
                    _usuarioIdCtrl.clear();
                    _fechaDesdeCtrl.clear();
                    _fechaHastaCtrl.clear();
                    ref.read(bitacoraQueryProvider.notifier).state =
                        const BitacoraQuery();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: bitacoraAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay registros para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(bitacoraListProvider);
                  await ref.read(bitacoraListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} eventos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data) _BitacoraCard(item: item),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(bitacoraQueryProvider.notifier).state =
                            query.copyWith(page: page);
                      },
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: DataCard(
                child: Text('No se pudo cargar bitacora. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BitacoraCard extends StatelessWidget {
  final BitacoraItem item;

  const _BitacoraCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.accion,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('Fecha: ${_formatDate(item.fechaHora)}'),
          Text('Entidad: ${item.entidad}'),
          Text('ID entidad: ${item.entidadId ?? '-'}'),
          Text('Usuario: ${_renderUser(item)}'),
          Text('IP: ${item.ipOrigen ?? '-'}'),
          Text('Detalle: ${_renderDetail(item.detalle)}'),
        ],
      ),
    );
  }
}

String _renderDetail(dynamic detail) {
  if (detail == null) {
    return '-';
  }
  if (detail is String) {
    return detail;
  }
  return detail.toString();
}

String _renderUser(BitacoraItem item) {
  if ((item.username ?? '').isNotEmpty && (item.email ?? '').isNotEmpty) {
    return '${item.username} (${item.email})';
  }
  if ((item.username ?? '').isNotEmpty) {
    return item.username!;
  }
  if ((item.email ?? '').isNotEmpty) {
    return item.email!;
  }
  return '-';
}

String _formatDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }

  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} ${two(parsed.hour)}:${two(parsed.minute)}';
}
