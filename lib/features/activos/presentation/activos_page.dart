import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/ui/status_badge.dart';
import '../data/activos_repository.dart';
import '../domain/activo_models.dart';
import 'activos_controller.dart';

class ActivosPage extends ConsumerStatefulWidget {
  const ActivosPage({super.key});

  @override
  ConsumerState<ActivosPage> createState() => _ActivosPageState();
}

class _ActivosPageState extends ConsumerState<ActivosPage> {
  late final TextEditingController _etiquetaCtrl;
  late final TextEditingController _provinciaCtrl;
  late final TextEditingController _modeloCtrl;
  late final TextEditingController _fabricanteCtrl;

  @override
  void initState() {
    super.initState();
    _etiquetaCtrl = TextEditingController();
    _provinciaCtrl = TextEditingController();
    _modeloCtrl = TextEditingController();
    _fabricanteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _etiquetaCtrl.dispose();
    _provinciaCtrl.dispose();
    _modeloCtrl.dispose();
    _fabricanteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(activosQueryProvider);
    final activosAsync = ref.watch(activosListProvider);
    final auth = ref.watch(authControllerProvider);
    final canMutate = _canMutate(auth.user?.rol);

    return Column(
      children: [
        PageHeader(
          title: 'Activos',
          subtitle: 'Inventario y estado operativo',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canMutate)
                IconButton(
                  onPressed: () => _openActivoForm(context),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Crear activo',
                ),
              IconButton(
                onPressed: () => ref.refresh(activosListProvider),
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar',
              ),
            ],
          ),
        ),
        DataCard(
          child: Column(
            children: [
              TextField(
                controller: _etiquetaCtrl,
                decoration: InputDecoration(
                  labelText: 'Etiqueta',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _etiquetaCtrl.clear();
                      ref.read(activosQueryProvider.notifier).state =
                          query.copyWith(
                        page: 1,
                        etiqueta: '',
                      );
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
                onSubmitted: (value) {
                  ref.read(activosQueryProvider.notifier).state =
                      query.copyWith(
                    page: 1,
                    etiqueta: value.trim(),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _provinciaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Provincia',
                      ),
                      onSubmitted: (value) {
                        ref.read(activosQueryProvider.notifier).state =
                            query.copyWith(
                          page: 1,
                          provincia: value.trim(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _modeloCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                      ),
                      onSubmitted: (value) {
                        ref.read(activosQueryProvider.notifier).state =
                            query.copyWith(
                          page: 1,
                          modelo: value.trim(),
                        );
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
                      controller: _fabricanteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Fabricante',
                      ),
                      onSubmitted: (value) {
                        ref.read(activosQueryProvider.notifier).state =
                            query.copyWith(
                          page: 1,
                          fabricante: value.trim(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      isExpanded: true,
                      value: query.activo,
                      decoration:
                          const InputDecoration(labelText: 'Estado registro'),
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Activos'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Inactivos'),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(activosQueryProvider.notifier).state =
                            value == null
                                ? query.copyWith(page: 1, clearActivo: true)
                                : query.copyWith(page: 1, activo: value);
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
                    _etiquetaCtrl.clear();
                    _provinciaCtrl.clear();
                    _modeloCtrl.clear();
                    _fabricanteCtrl.clear();
                    ref.read(activosQueryProvider.notifier).state =
                        const ActivosQuery();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: activosAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay activos para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(activosListProvider);
                  await ref.read(activosListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} activos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data)
                      _ActivoCard(
                        item: item,
                        onTap: () => _openActivoDetail(context, item.idActivo),
                      ),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(activosQueryProvider.notifier).state =
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
                child: Text('No se pudo cargar activos. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openActivoDetail(BuildContext context, String activoId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ActivoDetailSheet(activoId: activoId),
      ),
    );
  }

  Future<void> _openActivoForm(
    BuildContext context, {
    ActivoItem? initial,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ActivoFormSheet(
          initial: initial,
          onSaved: () {
            ref.invalidate(activosListProvider);
          },
        ),
      ),
    );
  }

  bool _canMutate(TipoRol? rol) {
    return rol == TipoRol.autorizador || rol == TipoRol.administrador;
  }
}

class _ActivoCard extends StatelessWidget {
  final ActivoItem item;
  final VoidCallback onTap;

  const _ActivoCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DataCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.etiqueta,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
                const SizedBox(width: 8),
                StatusBadge(
                  label: item.activo ? 'Activo' : 'Inactivo',
                  color: item.activo ? AppColors.success : AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Equipo: ${item.descripcionEquipo}'),
            Text('Tipo: ${item.tipoActivo}'),
            Text('Estado: ${item.estadoActivo}'),
            Text('Serial: ${item.serial}'),
            Text('Modelo: ${item.modelo ?? '-'}'),
            Text('Fabricante: ${item.fabricante ?? '-'}'),
            Text('Provincia: ${item.provincia ?? '-'}'),
            Text('Sucursal: ${item.sucursal ?? '-'}'),
          ],
        ),
      ),
    );
  }
}

class ActivoDetailSheet extends ConsumerWidget {
  final String activoId;

  const ActivoDetailSheet({super.key, required this.activoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextoAsync = ref.watch(activoContextoProvider(activoId));
    final auth = ref.watch(authControllerProvider);
    final canMutate = auth.user?.rol == TipoRol.autorizador ||
        auth.user?.rol == TipoRol.administrador;

    return Scaffold(
      appBar: AppBar(
        title: Text('Activo #$activoId'),
      ),
      body: contextoAsync.when(
        data: (contexto) {
          final activo = contexto.activo;
          final asignacion = contexto.asignacionActiva;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              DataCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activo.etiqueta,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusBadge(
                          label: activo.activo ? 'Activo' : 'Inactivo',
                          color: activo.activo
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DetailLine(label: 'Serial', value: activo.serial),
                    _DetailLine(
                      label: 'Descripcion equipo',
                      value: activo.descripcionEquipo,
                    ),
                    _DetailLine(label: 'Tipo', value: activo.tipoActivo),
                    _DetailLine(label: 'Estado', value: activo.estadoActivo),
                    _DetailLine(label: 'Modelo', value: activo.modelo ?? '-'),
                    _DetailLine(
                      label: 'Fabricante',
                      value: activo.fabricante ?? '-',
                    ),
                    _DetailLine(
                      label: 'Anio fabricacion',
                      value: _formatDate(activo.anioFabricacion),
                    ),
                    _DetailLine(
                      label: 'Provincia',
                      value: activo.provincia ?? '-',
                    ),
                    _DetailLine(
                      label: 'Sucursal',
                      value: activo.sucursal ?? '-',
                    ),
                    _DetailLine(
                      label: 'Observacion',
                      value: activo.observacion ?? '-',
                    ),
                    if (canMutate) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  _openEditForm(context, activo, ref),
                              child: const Text('Editar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () =>
                                  _openChangeState(context, activo, ref),
                              child: const Text('Cambiar estado'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              DataCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contexto operativo',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    if (asignacion == null)
                      const Text('Sin asignacion activa.')
                    else ...[
                      _DetailLine(
                        label: 'Asignacion',
                        value: asignacion.idAsignacionActivo,
                      ),
                      _DetailLine(
                        label: 'Fecha inicio',
                        value: _formatDate(asignacion.fechaInicio),
                      ),
                      _DetailLine(
                        label: 'Estado asignacion',
                        value: asignacion.estado,
                      ),
                      _DetailLine(
                        label: 'PDV',
                        value: asignacion.pdv.nombreNegocio,
                      ),
                      _DetailLine(
                        label: 'Telefono PDV',
                        value: asignacion.pdv.telefono ?? '-',
                      ),
                      _DetailLine(
                        label: 'Canal',
                        value: asignacion.pdv.canal,
                      ),
                      _DetailLine(
                        label: 'Supracanal',
                        value: asignacion.pdv.supracanal,
                      ),
                      _DetailLine(
                        label: 'Observacion asignacion',
                        value: asignacion.observacion ?? '-',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: DataCard(
            child: Text('No se pudo cargar el activo. $error'),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditForm(
    BuildContext context,
    ActivoItem activo,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ActivoFormSheet(
          initial: activo,
          onSaved: () {
            ref.invalidate(activosListProvider);
            ref.invalidate(activoContextoProvider(activo.idActivo));
          },
        ),
      ),
    );
  }

  Future<void> _openChangeState(
    BuildContext context,
    ActivoItem activo,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController(text: activo.estadoActivo);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cambiar estado del activo'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nuevo estado'),
            textCapitalization: TextCapitalization.characters,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || controller.text.trim().isEmpty) return;

    final result = await ref
        .read(activosRepositoryProvider)
        .changeEstadoActivo(activo.idActivo, controller.text.trim());

    if (!context.mounted) return;

    if (result.isSuccess) {
      ref.invalidate(activosListProvider);
      ref.invalidate(activoContextoProvider(activo.idActivo));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.failure?.message ?? 'No se pudo actualizar')),
      );
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

class ActivoFormSheet extends ConsumerStatefulWidget {
  final ActivoItem? initial;
  final VoidCallback onSaved;

  const ActivoFormSheet({
    super.key,
    required this.initial,
    required this.onSaved,
  });

  @override
  ConsumerState<ActivoFormSheet> createState() => _ActivoFormSheetState();
}

class _ActivoFormSheetState extends ConsumerState<ActivoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serialCtrl;
  late final TextEditingController _etiquetaCtrl;
  late final TextEditingController _tipoActivoCtrl;
  late final TextEditingController _estadoActivoCtrl;
  late final TextEditingController _descripcionEquipoCtrl;
  late final TextEditingController _fabricanteCtrl;
  late final TextEditingController _modeloCtrl;
  late final TextEditingController _anioCtrl;
  late final TextEditingController _provinciaCtrl;
  late final TextEditingController _sucursalCtrl;
  late final TextEditingController _observacionCtrl;
  bool _activo = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _serialCtrl = TextEditingController(text: initial?.serial ?? '');
    _etiquetaCtrl = TextEditingController(text: initial?.etiqueta ?? '');
    _tipoActivoCtrl = TextEditingController(text: initial?.tipoActivo ?? '');
    _estadoActivoCtrl =
        TextEditingController(text: initial?.estadoActivo ?? '');
    _descripcionEquipoCtrl =
        TextEditingController(text: initial?.descripcionEquipo ?? '');
    _fabricanteCtrl = TextEditingController(text: initial?.fabricante ?? '');
    _modeloCtrl = TextEditingController(text: initial?.modelo ?? '');
    _anioCtrl =
        TextEditingController(text: _normalizeDate(initial?.anioFabricacion));
    _provinciaCtrl = TextEditingController(text: initial?.provincia ?? '');
    _sucursalCtrl = TextEditingController(text: initial?.sucursal ?? '');
    _observacionCtrl = TextEditingController(text: initial?.observacion ?? '');
    _activo = initial?.activo ?? true;
  }

  @override
  void dispose() {
    _serialCtrl.dispose();
    _etiquetaCtrl.dispose();
    _tipoActivoCtrl.dispose();
    _estadoActivoCtrl.dispose();
    _descripcionEquipoCtrl.dispose();
    _fabricanteCtrl.dispose();
    _modeloCtrl.dispose();
    _anioCtrl.dispose();
    _provinciaCtrl.dispose();
    _sucursalCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Crear activo' : 'Editar activo'),
      ),
      body: ListView(
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
                TextFormField(
                  controller: _serialCtrl,
                  decoration: const InputDecoration(labelText: 'Serial'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _etiquetaCtrl,
                  decoration: const InputDecoration(labelText: 'Etiqueta'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tipoActivoCtrl,
                  decoration: const InputDecoration(labelText: 'Tipo activo'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estadoActivoCtrl,
                  decoration: const InputDecoration(labelText: 'Estado activo'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionEquipoCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Descripcion equipo'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Requerido'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fabricanteCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Fabricante'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modeloCtrl,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _anioCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Anio fabricacion (YYYY-MM-DD)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _provinciaCtrl,
                  decoration: const InputDecoration(labelText: 'Provincia'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sucursalCtrl,
                  decoration: const InputDecoration(labelText: 'Sucursal'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacionCtrl,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(labelText: 'Observacion'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  title: const Text('Registro activo'),
                  contentPadding: EdgeInsets.zero,
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

    final payload = ActivoUpsertPayload(
      serial: _serialCtrl.text,
      etiqueta: _etiquetaCtrl.text,
      descripcionEquipo: _descripcionEquipoCtrl.text,
      fabricante: _fabricanteCtrl.text,
      modelo: _modeloCtrl.text,
      anioFabricacion: _anioCtrl.text,
      provincia: _provinciaCtrl.text,
      observacion: _observacionCtrl.text,
      activo: _activo,
      tipoActivo: _tipoActivoCtrl.text,
      estadoActivo: _estadoActivoCtrl.text,
      sucursal: _sucursalCtrl.text,
    );

    final repository = ref.read(activosRepositoryProvider);
    final result = widget.initial == null
        ? await repository.createActivo(payload)
        : await repository.updateActivo(widget.initial!.idActivo, payload);

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

  String _normalizeDate(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
