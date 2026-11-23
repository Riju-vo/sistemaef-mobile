import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../core/errors/result.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/ui/status_badge.dart';
import '../../activos/domain/activo_models.dart' show ActivoItem;
import '../data/asignaciones_repository.dart';
import '../domain/asignacion_models.dart';
import 'asignaciones_controller.dart';

class AsignacionesPage extends ConsumerStatefulWidget {
  const AsignacionesPage({super.key});

  @override
  ConsumerState<AsignacionesPage> createState() => _AsignacionesPageState();
}

class _AsignacionesPageState extends ConsumerState<AsignacionesPage> {
  late final TextEditingController _activoCtrl;
  late final TextEditingController _etiquetaCtrl;
  late final TextEditingController _pdvCtrl;
  late final TextEditingController _estadoCtrl;

  @override
  void initState() {
    super.initState();
    _activoCtrl = TextEditingController();
    _etiquetaCtrl = TextEditingController();
    _pdvCtrl = TextEditingController();
    _estadoCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _activoCtrl.dispose();
    _etiquetaCtrl.dispose();
    _pdvCtrl.dispose();
    _estadoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(asignacionesQueryProvider);
    final asignacionesAsync = ref.watch(asignacionesListProvider);
    final auth = ref.watch(authControllerProvider);
    final canMutate = _canMutate(auth.user?.rol);

    return Column(
      children: [
        PageHeader(
          title: 'Asignaciones',
          subtitle: 'Crear, listar y finalizar asignaciones',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canMutate)
                IconButton(
                  onPressed: () => _openCreateSheet(context),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Crear asignacion',
                ),
              IconButton(
                onPressed: () => ref.refresh(asignacionesListProvider),
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar',
              ),
            ],
          ),
        ),
        DataCard(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _activoCtrl,
                      decoration: const InputDecoration(labelText: 'ID activo'),
                      onSubmitted: (value) {
                        ref.read(asignacionesQueryProvider.notifier).state =
                            query.copyWith(page: 1, idActivo: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _etiquetaCtrl,
                      decoration: const InputDecoration(labelText: 'Etiqueta'),
                      onSubmitted: (value) {
                        ref.read(asignacionesQueryProvider.notifier).state =
                            query.copyWith(page: 1, etiqueta: value.trim());
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
                      controller: _pdvCtrl,
                      decoration: const InputDecoration(labelText: 'PDV'),
                      onSubmitted: (value) {
                        ref.read(asignacionesQueryProvider.notifier).state =
                            query.copyWith(page: 1, pdv: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _estadoCtrl,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      onSubmitted: (value) {
                        ref.read(asignacionesQueryProvider.notifier).state =
                            query.copyWith(page: 1, estado: value.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      isExpanded: true,
                      value: query.activa,
                      decoration: const InputDecoration(labelText: 'Activa'),
                      items: const [
                        DropdownMenuItem<bool?>(
                            value: null, child: Text('Todas')),
                        DropdownMenuItem<bool?>(
                            value: true, child: Text('Solo activas')),
                        DropdownMenuItem<bool?>(
                            value: false, child: Text('Solo finalizadas')),
                      ],
                      onChanged: (value) {
                        ref.read(asignacionesQueryProvider.notifier).state =
                            value == null
                                ? query.copyWith(page: 1, clearActiva: true)
                                : query.copyWith(page: 1, activa: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _activoCtrl.clear();
                          _etiquetaCtrl.clear();
                          _pdvCtrl.clear();
                          _estadoCtrl.clear();
                          ref.read(asignacionesQueryProvider.notifier).state =
                              const AsignacionesQuery();
                        },
                        child: const Text('Limpiar filtros'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: asignacionesAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay asignaciones para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(asignacionesListProvider);
                  await ref.read(asignacionesListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} asignaciones',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data)
                      _AsignacionCard(
                        item: item,
                        canMutate: canMutate,
                        onFinalizar: item.fechaFin == null
                            ? () => _openFinalizarSheet(context, item)
                            : null,
                      ),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(asignacionesQueryProvider.notifier).state =
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
                child: Text('No se pudo cargar asignaciones. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _canMutate(TipoRol? rol) {
    return rol == TipoRol.autorizador || rol == TipoRol.administrador;
  }

  Future<void> _openCreateSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CreateAsignacionSheet(
          onSaved: () => ref.invalidate(asignacionesListProvider),
        ),
      ),
    );
  }

  Future<void> _openFinalizarSheet(
    BuildContext context,
    AsignacionItem item,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: FinalizarAsignacionSheet(
          item: item,
          onSaved: () => ref.invalidate(asignacionesListProvider),
        ),
      ),
    );
  }
}

class _AsignacionCard extends StatelessWidget {
  final AsignacionItem item;
  final bool canMutate;
  final VoidCallback? onFinalizar;

  const _AsignacionCard({
    required this.item,
    required this.canMutate,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    final activa = item.fechaFin == null;

    return DataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.etiquetaActivo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(
                label: activa ? 'Activa' : 'Finalizada',
                color: activa ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Asignacion: ${item.idAsignacionActivo}'),
          Text('PDV: ${item.nombrePdv}'),
          Text('Estado: ${item.estado}'),
          Text('Inicio: ${item.fechaInicio}'),
          Text('Fin: ${item.fechaFin ?? '-'}'),
          if ((item.observacion ?? '').trim().isNotEmpty)
            Text('Observacion: ${item.observacion}'),
          if (canMutate && activa && onFinalizar != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onFinalizar,
                child: const Text('Finalizar asignacion'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CreateAsignacionSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const CreateAsignacionSheet({super.key, required this.onSaved});

  @override
  ConsumerState<CreateAsignacionSheet> createState() =>
      _CreateAsignacionSheetState();
}

class _CreateAsignacionSheetState extends ConsumerState<CreateAsignacionSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _idActivo;
  String? _idPdv;
  final _fechaInicioCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController(text: 'ACTIVA');
  final _observacionCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _fechaInicioCtrl.dispose();
    _estadoCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear asignacion')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          ref.read(asignacionesRepositoryProvider).listActivosDisponibles(),
          ref.read(asignacionesRepositoryProvider).listPdvsActivos(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final activosResult = snapshot.data![0] as Result<List<ActivoItem>>;
          final pdvsResult = snapshot.data![1] as Result<List<PdvOption>>;

          if (!activosResult.isSuccess ||
              !pdvsResult.isSuccess ||
              activosResult.data == null ||
              pdvsResult.data == null) {
            return const Center(
              child: Text('No se pudieron cargar los datos para crear.'),
            );
          }

          final activos = activosResult.data!;
          final pdvs = pdvsResult.data!;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (_error != null) ...[
                DataCard(child: Text(_error!)),
                const SizedBox(height: 8),
              ],
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _idActivo,
                      decoration: const InputDecoration(labelText: 'Activo'),
                      items: activos
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.idActivo,
                              child: Text(
                                  '${item.etiqueta} - ${item.estadoActivo}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _idActivo = value),
                      validator: (value) => value == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _idPdv,
                      decoration: const InputDecoration(labelText: 'PDV'),
                      items: pdvs
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.idPdv,
                              child: Text(item.nombreNegocio),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _idPdv = value),
                      validator: (value) => value == null ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fechaInicioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Fecha inicio (YYYY-MM-DD)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _estadoCtrl,
                      decoration: const InputDecoration(labelText: 'Estado'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _observacionCtrl,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(labelText: 'Observacion'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(_saving ? 'Guardando...' : 'Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true ||
        _idActivo == null ||
        _idPdv == null) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final result =
        await ref.read(asignacionesRepositoryProvider).createAsignacion(
              idActivo: _idActivo!,
              idPdv: _idPdv!,
              fechaInicio: _fechaInicioCtrl.text,
              estado: _estadoCtrl.text,
              observacion: _observacionCtrl.text,
            );

    if (!mounted) return;

    setState(() {
      _saving = false;
      _error = result.isSuccess ? null : result.failure?.message;
    });

    if (result.isSuccess) {
      widget.onSaved();
      Navigator.of(context).pop();
    }
  }
}

class FinalizarAsignacionSheet extends ConsumerStatefulWidget {
  final AsignacionItem item;
  final VoidCallback onSaved;

  const FinalizarAsignacionSheet({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<FinalizarAsignacionSheet> createState() =>
      _FinalizarAsignacionSheetState();
}

class _FinalizarAsignacionSheetState
    extends ConsumerState<FinalizarAsignacionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _estadoActivoCtrl = TextEditingController();
  final _fechaFinCtrl = TextEditingController();
  final _estadoCtrl = TextEditingController(text: 'FINALIZADA');
  final _observacionCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _estadoActivoCtrl.dispose();
    _fechaFinCtrl.dispose();
    _estadoCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar asignacion')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          DataCard(
            child: Text(
              'Activo ${widget.item.etiquetaActivo} - PDV ${widget.item.nombrePdv}',
            ),
          ),
          const SizedBox(height: 8),
          if (_error != null) ...[
            DataCard(child: Text(_error!)),
            const SizedBox(height: 8),
          ],
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _estadoActivoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo estado del activo',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fechaFinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Fecha fin (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estadoCtrl,
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacionCtrl,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Observacion'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Guardando...' : 'Guardar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final result =
        await ref.read(asignacionesRepositoryProvider).finalizarAsignacion(
              id: widget.item.idAsignacionActivo,
              estadoActivo: _estadoActivoCtrl.text.trim(),
              fechaFin: _fechaFinCtrl.text,
              estado: _estadoCtrl.text,
              observacion: _observacionCtrl.text,
            );

    if (!mounted) return;

    setState(() {
      _saving = false;
      _error = result.isSuccess ? null : result.failure?.message;
    });

    if (result.isSuccess) {
      widget.onSaved();
      Navigator.of(context).pop();
    }
  }
}
