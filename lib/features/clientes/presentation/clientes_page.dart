import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/ui/status_badge.dart';
import '../data/clientes_repository.dart';
import '../domain/cliente_models.dart';
import 'clientes_controller.dart';

class ClientesPage extends ConsumerStatefulWidget {
  const ClientesPage({super.key});

  @override
  ConsumerState<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends ConsumerState<ClientesPage> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _codigoCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _codigoCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(clientesQueryProvider);
    final clientesAsync = ref.watch(clientesListProvider);
    final auth = ref.watch(authControllerProvider);
    final canMutate = _canMutate(auth.user?.rol);

    return Column(
      children: [
        PageHeader(
          title: 'Clientes',
          subtitle: 'Directorio operativo y carga masiva',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canMutate)
                IconButton(
                  onPressed: () => _openImportSheet(context),
                  icon: const Icon(Icons.upload_file_outlined),
                  tooltip: 'Importar clientes',
                ),
              if (canMutate)
                IconButton(
                  onPressed: () => _openClienteForm(context),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Crear cliente',
                ),
              IconButton(
                onPressed: () => ref.refresh(clientesListProvider),
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
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      onSubmitted: (value) {
                        ref.read(clientesQueryProvider.notifier).state =
                            query.copyWith(page: 1, nombre: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _codigoCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Codigo cliente',
                      ),
                      onSubmitted: (value) {
                        ref.read(clientesQueryProvider.notifier).state = query
                            .copyWith(page: 1, codigoCliente: value.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CategoriaSofia?>(
                      isExpanded: true,
                      value: query.categoriaSofia,
                      decoration: const InputDecoration(
                        labelText: 'Categoria Sofia',
                      ),
                      items: const [
                        DropdownMenuItem<CategoriaSofia?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        DropdownMenuItem<CategoriaSofia?>(
                          value: CategoriaSofia.a,
                          child: Text('A'),
                        ),
                        DropdownMenuItem<CategoriaSofia?>(
                          value: CategoriaSofia.b,
                          child: Text('B'),
                        ),
                        DropdownMenuItem<CategoriaSofia?>(
                          value: CategoriaSofia.c,
                          child: Text('C'),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(clientesQueryProvider.notifier).state =
                            value == null
                                ? query.copyWith(
                                    page: 1,
                                    clearCategoriaSofia: true,
                                  )
                                : query.copyWith(
                                    page: 1,
                                    categoriaSofia: value,
                                  );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      isExpanded: true,
                      value: query.activo,
                      decoration: const InputDecoration(labelText: 'Activo'),
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
                        ref.read(clientesQueryProvider.notifier).state =
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
                    _nombreCtrl.clear();
                    _codigoCtrl.clear();
                    ref.read(clientesQueryProvider.notifier).state =
                        const ClientesQuery();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: clientesAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay clientes para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(clientesListProvider);
                  await ref.read(clientesListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} clientes',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data)
                      _ClienteCard(
                        item: item,
                        canMutate: canMutate,
                        onEdit: () => _openClienteForm(context, item: item),
                        onDeactivate: item.activo
                            ? () => _confirmDeactivate(context, item)
                            : null,
                      ),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(clientesQueryProvider.notifier).state =
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
                child: Text('No se pudo cargar clientes. $error'),
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

  Future<void> _openClienteForm(
    BuildContext context, {
    ClienteItem? item,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClienteFormSheet(
          item: item,
          onSaved: () => ref.invalidate(clientesListProvider),
        ),
      ),
    );
  }

  Future<void> _openImportSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ImportClientesSheet(
          onFinished: () => ref.invalidate(clientesListProvider),
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(
      BuildContext context, ClienteItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar cliente'),
        content: Text(
          'Se desactivara ${item.nombre} (${item.codigoCliente}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(clientesRepositoryProvider);
    final result = await repository.removeCliente(item.idCliente);

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ref.invalidate(clientesListProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Cliente desactivado')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.failure?.message ?? 'No se pudo desactivar el cliente',
        ),
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final ClienteItem item;
  final bool canMutate;
  final VoidCallback onEdit;
  final VoidCallback? onDeactivate;

  const _ClienteCard({
    required this.item,
    required this.canMutate,
    required this.onEdit,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return DataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusBadge(
                label: item.activo ? 'Activo' : 'Inactivo',
                color: item.activo ? AppColors.success : AppColors.muted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Codigo: ${item.codigoCliente}'),
          Text('Categoria Sofia: ${_categoriaLabel(item.categoriaSofia)}'),
          Text('Telefono: ${item.telefono ?? '-'}'),
          Text('Direccion: ${item.direccion ?? '-'}'),
          Text(
            'Ubicacion: ${item.latitud != null && item.longitud != null ? '${item.latitud}, ${item.longitud}' : '-'}',
          ),
          if ((item.direccionId ?? '').trim().isNotEmpty)
            Text('Direccion ID: ${item.direccionId}'),
          if (canMutate) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    child: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: onDeactivate,
                    child: const Text('Desactivar'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _categoriaLabel(CategoriaSofia? value) {
    return value == null ? '-' : categoriaSofiaToApi(value);
  }
}

class ClienteFormSheet extends ConsumerStatefulWidget {
  final ClienteItem? item;
  final VoidCallback onSaved;

  const ClienteFormSheet({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<ClienteFormSheet> createState() => _ClienteFormSheetState();
}

class _ClienteFormSheetState extends ConsumerState<ClienteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _direccionIdCtrl;
  late final TextEditingController _latitudCtrl;
  late final TextEditingController _longitudCtrl;
  late CategoriaSofia _categoriaSofia;
  late bool _activo;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codigoCtrl = TextEditingController(text: item?.codigoCliente ?? '');
    _nombreCtrl = TextEditingController(text: item?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: item?.telefono ?? '');
    _direccionCtrl = TextEditingController(text: item?.direccion ?? '');
    _direccionIdCtrl = TextEditingController(text: item?.direccionId ?? '');
    _latitudCtrl = TextEditingController(
      text: item?.latitud?.toString() ?? '',
    );
    _longitudCtrl = TextEditingController(
      text: item?.longitud?.toString() ?? '',
    );
    _categoriaSofia = item?.categoriaSofia ?? CategoriaSofia.a;
    _activo = item?.activo ?? true;
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _direccionIdCtrl.dispose();
    _latitudCtrl.dispose();
    _longitudCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar cliente' : 'Crear cliente'),
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
                  controller: _codigoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Codigo cliente',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return 'El codigo cliente es requerido';
                    }
                    if (!RegExp(r'^\d+$').hasMatch(text)) {
                      return 'Solo se permiten numeros';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres';
                    }
                    if (text.length > 150) {
                      return 'El nombre no puede exceder 150 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoCtrl,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                  validator: (value) {
                    if ((value ?? '').trim().length > 30) {
                      return 'El telefono no puede exceder 30 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CategoriaSofia>(
                  value: _categoriaSofia,
                  decoration: const InputDecoration(
                    labelText: 'Categoria Sofia',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: CategoriaSofia.a,
                      child: Text('A'),
                    ),
                    DropdownMenuItem(
                      value: CategoriaSofia.b,
                      child: Text('B'),
                    ),
                    DropdownMenuItem(
                      value: CategoriaSofia.c,
                      child: Text('C'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoriaSofia = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(labelText: 'Direccion'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionIdCtrl,
                  decoration: const InputDecoration(labelText: 'Direccion ID'),
                  validator: (value) {
                    if ((value ?? '').trim().length > 100) {
                      return 'Direccion ID no puede exceder 100 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(labelText: 'Latitud'),
                        validator: (value) {
                          final text =
                              (value ?? '').trim().replaceAll(',', '.');
                          if (text.isEmpty) {
                            return null;
                          }
                          final parsed = double.tryParse(text);
                          if (parsed == null) {
                            return 'Latitud invalida';
                          }
                          if (parsed < -90 || parsed > 90) {
                            return 'Debe estar entre -90 y 90';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: 'Longitud'),
                        validator: (value) {
                          final text =
                              (value ?? '').trim().replaceAll(',', '.');
                          if (text.isEmpty) {
                            return null;
                          }
                          final parsed = double.tryParse(text);
                          if (parsed == null) {
                            return 'Longitud invalida';
                          }
                          if (parsed < -180 || parsed > 180) {
                            return 'Debe estar entre -180 y 180';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _activo,
                  title: const Text('Registro activo'),
                  onChanged: (value) => setState(() => _activo = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Guardando...' : 'Guardar cliente'),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final payload = ClienteUpsertPayload(
      codigoCliente: _codigoCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      categoriaSofia: _categoriaSofia,
      direccion: _direccionCtrl.text.trim(),
      direccionId: _direccionIdCtrl.text.trim(),
      latitud: _parseNullableDouble(_latitudCtrl.text),
      longitud: _parseNullableDouble(_longitudCtrl.text),
      activo: _activo,
    );

    final repository = ref.read(clientesRepositoryProvider);
    final result = widget.item == null
        ? await repository.createCliente(payload)
        : await repository.updateCliente(widget.item!.idCliente, payload);

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      widget.onSaved();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.item == null
                ? 'Cliente creado correctamente'
                : 'Cliente actualizado correctamente',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = false;
      _error = result.failure?.message ?? 'No se pudo guardar el cliente';
    });
  }

  double? _parseNullableDouble(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }
}

class ImportClientesSheet extends ConsumerStatefulWidget {
  final VoidCallback onFinished;

  const ImportClientesSheet({
    super.key,
    required this.onFinished,
  });

  @override
  ConsumerState<ImportClientesSheet> createState() =>
      _ImportClientesSheetState();
}

class _ImportClientesSheetState extends ConsumerState<ImportClientesSheet> {
  PlatformFile? _selectedFile;
  ClienteImportJob? _job;
  String? _error;
  bool _uploading = false;
  Timer? _pollingTimer;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carga masiva de clientes')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_error != null) ...[
            DataCard(child: Text(_error!)),
            const SizedBox(height: 8),
          ],
          if (_job == null) ...[
            DataCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sube un archivo CSV para importar clientes y PDVs relacionados.',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _selectedFile?.name ?? 'Seleccionar archivo CSV',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _uploading || _selectedFile == null
                          ? null
                          : _uploadFile,
                      child: Text(
                        _uploading ? 'Subiendo...' : 'Subir y procesar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            DataCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _job!.nombreArchivo,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      StatusBadge(
                        label: _job!.estado,
                        color: _job!.estado == 'FALLIDO'
                            ? AppColors.danger
                            : _job!.estado == 'COMPLETADO'
                                ? AppColors.success
                                : AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _job!.progressPercent / 100,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text('Progreso: ${_job!.progressPercent}%'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        label: 'Totales',
                        value: _job!.filasTotales.toString(),
                      ),
                      _StatChip(
                        label: 'Procesadas',
                        value: _job!.filasProcesadas.toString(),
                      ),
                      _StatChip(
                        label: 'Creados',
                        value: _job!.creados.toString(),
                      ),
                      _StatChip(
                        label: 'Actualizados',
                        value: _job!.actualizados.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_job!.errores.isNotEmpty) ...[
              const SizedBox(height: 12),
              DataCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Errores encontrados (${_job!.errores.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    for (final error in _job!.errores)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Fila ${error.linea}: ${error.error}${(error.fila ?? '').trim().isNotEmpty ? ' | ${error.fila}' : ''}',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    if ((file.bytes?.isEmpty ?? true) &&
        (file.path == null || file.path!.isEmpty)) {
      setState(() {
        _error = 'No se pudo leer el archivo seleccionado';
      });
      return;
    }

    setState(() {
      _selectedFile = file;
    });
  }

  Future<void> _uploadFile() async {
    final file = _selectedFile;
    if (file == null || file.bytes == null) {
      setState(() {
        _error = 'Selecciona un archivo CSV valido';
      });
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
    });

    final repository = ref.read(clientesRepositoryProvider);
    final result = await repository.uploadClientesCsv(
      CsvUploadPayload(bytes: file.bytes!, filename: file.name),
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess || result.data == null || result.data!.isEmpty) {
      setState(() {
        _uploading = false;
        _error = result.failure?.message ?? 'No se pudo iniciar la importacion';
      });
      return;
    }

    _startPolling(result.data!);
  }

  void _startPolling(String jobId) {
    _pollingTimer?.cancel();
    _poll(jobId);
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _poll(jobId);
    });
  }

  Future<void> _poll(String jobId) async {
    final repository = ref.read(clientesRepositoryProvider);
    final result = await repository.getImportJobStatus(jobId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess || result.data == null) {
      setState(() {
        _uploading = false;
        _error = result.failure?.message ??
            'No se pudo consultar el progreso de la importacion';
      });
      _pollingTimer?.cancel();
      return;
    }

    final job = result.data!;
    setState(() {
      _job = job;
      _uploading = !job.isFinished;
    });

    if (job.isFinished) {
      _pollingTimer?.cancel();
      widget.onFinished();
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
