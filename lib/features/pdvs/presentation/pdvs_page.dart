import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/ui/status_badge.dart';
import '../data/pdvs_repository.dart';
import '../domain/pdv_models.dart';
import 'pdvs_controller.dart';

class PdvsPage extends ConsumerStatefulWidget {
  const PdvsPage({super.key});

  @override
  ConsumerState<PdvsPage> createState() => _PdvsPageState();
}

class _PdvsPageState extends ConsumerState<PdvsPage> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _nitCtrl;
  late final TextEditingController _tipoCanalCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController();
    _nitCtrl = TextEditingController();
    _tipoCanalCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _nitCtrl.dispose();
    _tipoCanalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(pdvsQueryProvider);
    final pdvsAsync = ref.watch(pdvsListProvider);
    final auth = ref.watch(authControllerProvider);
    final canMutate = _canMutate(auth.user?.rol);

    return Column(
      children: [
        PageHeader(
          title: 'PDVs',
          subtitle: 'Puntos de venta',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canMutate)
                IconButton(
                  onPressed: () => _openPdvForm(context),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Crear PDV',
                ),
              IconButton(
                onPressed: () => ref.refresh(pdvsListProvider),
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
                      decoration: const InputDecoration(
                        labelText: 'Nombre negocio',
                      ),
                      onSubmitted: (value) {
                        ref.read(pdvsQueryProvider.notifier).state =
                            query.copyWith(
                          page: 1,
                          nombreNegocio: value.trim(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _nitCtrl,
                      decoration: const InputDecoration(labelText: 'NIT'),
                      onSubmitted: (value) {
                        ref.read(pdvsQueryProvider.notifier).state =
                            query.copyWith(page: 1, nit: value.trim());
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
                      controller: _tipoCanalCtrl,
                      decoration: const InputDecoration(labelText: 'Canal'),
                      onSubmitted: (value) {
                        ref.read(pdvsQueryProvider.notifier).state =
                            query.copyWith(page: 1, tipoCanal: value.trim());
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<Supracanal?>(
                      isExpanded: true,
                      value: query.supracanal,
                      decoration: const InputDecoration(
                        labelText: 'Supracanal',
                      ),
                      items: const [
                        DropdownMenuItem<Supracanal?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        DropdownMenuItem<Supracanal?>(
                          value: Supracanal.onPremise,
                          child: Text('OnPremise'),
                        ),
                        DropdownMenuItem<Supracanal?>(
                          value: Supracanal.offPremise,
                          child: Text('OffPremise'),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(pdvsQueryProvider.notifier).state = value ==
                                null
                            ? query.copyWith(page: 1, clearSupracanal: true)
                            : query.copyWith(page: 1, supracanal: value);
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
                      value: query.activo,
                      decoration: const InputDecoration(labelText: 'Activo'),
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Si'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('No'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(pdvsQueryProvider.notifier).state = value ==
                                null
                            ? query.copyWith(page: 1, clearActivo: true)
                            : query.copyWith(page: 1, activo: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _nombreCtrl.clear();
                        _nitCtrl.clear();
                        _tipoCanalCtrl.clear();
                        ref.read(pdvsQueryProvider.notifier).state =
                            const PdvsQuery();
                      },
                      child: const Text('Limpiar filtros'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: pdvsAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay PDVs para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(pdvsListProvider);
                  await ref.read(pdvsListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} PDVs',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data)
                      _PdvCard(
                        item: item,
                        canMutate: canMutate,
                        onEdit: () => _openPdvForm(context, item: item),
                        onDeactivate: item.activo
                            ? () => _confirmDeactivate(context, item)
                            : null,
                      ),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(pdvsQueryProvider.notifier).state =
                            query.copyWith(page: page);
                      },
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: DataCard(child: Text('No se pudo cargar PDVs. $error')),
            ),
          ),
        ),
      ],
    );
  }

  bool _canMutate(TipoRol? rol) {
    return rol == TipoRol.autorizador || rol == TipoRol.administrador;
  }

  Future<void> _openPdvForm(
    BuildContext context, {
    PdvItem? item,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.96,
        child: PdvFormSheet(
          item: item,
          onSaved: () => ref.invalidate(pdvsListProvider),
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, PdvItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar PDV'),
        content: Text('Se desactivara ${item.nombreNegocio}.'),
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
    final repository = ref.read(pdvsRepositoryProvider);
    final result = await repository.removePdv(item.idPdv);

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ref.invalidate(pdvsListProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('PDV desactivado')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content:
            Text(result.failure?.message ?? 'No se pudo desactivar el PDV'),
      ),
    );
  }
}

class _PdvCard extends StatelessWidget {
  final PdvItem item;
  final bool canMutate;
  final VoidCallback onEdit;
  final VoidCallback? onDeactivate;

  const _PdvCard({
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
                  item.nombreNegocio,
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
          Text('Canal: ${item.tipoCanal}'),
          Text(
              'Supracanal: ${item.supracanal != null ? supracanalToApi(item.supracanal!) : '-'}'),
          Text('NIT: ${item.nit ?? '-'}'),
          Text('Telefono: ${item.telefono ?? '-'}'),
          Text('Direccion: ${item.direccion ?? '-'}'),
          Text('Direccion ID: ${item.direccionId}'),
          Text('Sucursal: ${item.sucursal ?? '-'}'),
          Text('Estado PDV: ${item.estadoPdv ?? '-'}'),
          Text(
            'Ubicacion: ${item.latitud != null && item.longitud != null ? '${item.latitud}, ${item.longitud}' : '-'}',
          ),
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
}

class PdvFormSheet extends ConsumerStatefulWidget {
  final PdvItem? item;
  final VoidCallback onSaved;

  const PdvFormSheet({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<PdvFormSheet> createState() => _PdvFormSheetState();
}

class _PdvFormSheetState extends ConsumerState<PdvFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _direccionIdCtrl;
  late final TextEditingController _latitudCtrl;
  late final TextEditingController _longitudCtrl;
  late final TextEditingController _nitCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _tipoCanalCtrl;
  late final TextEditingController _sucursalCtrl;
  late final TextEditingController _provinciaCtrl;
  late final TextEditingController _subcanalCtrl;
  late final TextEditingController _estadoPdvCtrl;
  Supracanal _selectedSupracanal = Supracanal.onPremise;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nombreCtrl = TextEditingController(text: item?.nombreNegocio ?? '');
    _direccionCtrl = TextEditingController(text: item?.direccion ?? '');
    _direccionIdCtrl = TextEditingController(text: item?.direccionId ?? '');
    _latitudCtrl = TextEditingController(text: item?.latitud?.toString() ?? '');
    _longitudCtrl =
        TextEditingController(text: item?.longitud?.toString() ?? '');
    _nitCtrl = TextEditingController(text: item?.nit ?? '');
    _telefonoCtrl = TextEditingController(text: item?.telefono ?? '');
    _tipoCanalCtrl = TextEditingController(text: item?.tipoCanal ?? '');
    _sucursalCtrl = TextEditingController(text: item?.sucursal ?? '');
    _provinciaCtrl = TextEditingController(text: item?.provincia ?? '');
    _subcanalCtrl = TextEditingController(text: item?.subcanal ?? '');
    _estadoPdvCtrl = TextEditingController(text: item?.estadoPdv ?? '');
    _selectedSupracanal = item?.supracanal ?? Supracanal.onPremise;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _direccionIdCtrl.dispose();
    _latitudCtrl.dispose();
    _longitudCtrl.dispose();
    _nitCtrl.dispose();
    _telefonoCtrl.dispose();
    _tipoCanalCtrl.dispose();
    _sucursalCtrl.dispose();
    _provinciaCtrl.dispose();
    _subcanalCtrl.dispose();
    _estadoPdvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar PDV' : 'Crear PDV'),
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
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre negocio',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.length < 2) {
                      return 'Nombre de negocio requerido';
                    }
                    if (text.length > 150) {
                      return 'No puede exceder 150 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tipoCanalCtrl,
                  decoration: const InputDecoration(labelText: 'Canal'),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return 'Canal requerido';
                    }
                    if (text.length > 100) {
                      return 'No puede exceder 100 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Supracanal>(
                  value: _selectedSupracanal,
                  decoration: const InputDecoration(
                    labelText: 'Supracanal',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: Supracanal.onPremise,
                      child: Text('OnPremise'),
                    ),
                    DropdownMenuItem(
                      value: Supracanal.offPremise,
                      child: Text('OffPremise'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSupracanal = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nitCtrl,
                  decoration: const InputDecoration(labelText: 'NIT'),
                  validator: (value) {
                    if ((value ?? '').trim().length > 50) {
                      return 'NIT no puede exceder 50 caracteres';
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
                      return 'Telefono no puede exceder 30 caracteres';
                    }
                    return null;
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
                  decoration: const InputDecoration(
                    labelText: 'Direccion ID',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) {
                      return 'Direccion ID requerido';
                    }
                    if (text.length > 100) {
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
                        decoration: const InputDecoration(
                          labelText: 'Latitud',
                        ),
                        validator: _validateLatitud,
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
                        decoration: const InputDecoration(
                          labelText: 'Longitud',
                        ),
                        validator: _validateLongitud,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sucursalCtrl,
                  decoration: const InputDecoration(labelText: 'Sucursal'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _provinciaCtrl,
                  decoration: const InputDecoration(labelText: 'Provincia'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subcanalCtrl,
                  decoration: const InputDecoration(labelText: 'Subcanal'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _estadoPdvCtrl,
                  decoration: const InputDecoration(labelText: 'Estado PDV'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Guardando...' : 'Guardar PDV'),
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

    final pdvPayload = PdvUpsertPayload(
      nombreNegocio: _nombreCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      direccionId: _direccionIdCtrl.text.trim(),
      latitud: _parseNullableDouble(_latitudCtrl.text),
      longitud: _parseNullableDouble(_longitudCtrl.text),
      nit: _nitCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      tipoCanal: _tipoCanalCtrl.text.trim(),
      supracanal: _selectedSupracanal,
      sucursal: _sucursalCtrl.text.trim(),
      provincia: _provinciaCtrl.text.trim(),
      subcanal: _subcanalCtrl.text.trim(),
      estadoPdv: _estadoPdvCtrl.text.trim(),
    );

    final repository = ref.read(pdvsRepositoryProvider);
    final result = widget.item != null
        ? await repository.updatePdv(widget.item!.idPdv, pdvPayload)
        : await repository.createPdv(pdvPayload);

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
                ? 'PDV creado correctamente'
                : 'PDV actualizado correctamente',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = false;
      _error = result.failure?.message ?? 'No se pudo guardar el PDV';
    });
  }

  String? _validateLatitud(String? value) {
    final text = (value ?? '').trim().replaceAll(',', '.');
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
  }

  String? _validateLongitud(String? value) {
    final text = (value ?? '').trim().replaceAll(',', '.');
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
  }

  double? _parseNullableDouble(String text) {
    final normalized = text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }
}
