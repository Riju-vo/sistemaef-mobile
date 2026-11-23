import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/page_header.dart';
import '../data/catalogos_repository.dart';
import '../domain/catalogo_models.dart';
import 'catalogos_controller.dart';

class CatalogosPage extends ConsumerStatefulWidget {
  const CatalogosPage({super.key});

  @override
  ConsumerState<CatalogosPage> createState() => _CatalogosPageState();
}

class _CatalogosPageState extends ConsumerState<CatalogosPage> {
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isAdmin = auth.user?.rol == TipoRol.administrador;
    final itemsAsync = ref.watch(catalogItemsProvider);

    if (!isAdmin) {
      return const Column(
        children: [
          PageHeader(
            title: 'Catalogos',
            subtitle: 'Administracion de roles del sistema',
          ),
          SizedBox(height: 8),
          DataCard(
            child: Text('Esta seccion es exclusiva de administradores.'),
          ),
        ],
      );
    }

    return Column(
      children: [
        PageHeader(
          title: 'Catalogos',
          subtitle: 'Administracion de roles del sistema',
          action: IconButton(
            onPressed: () => ref.refresh(catalogItemsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: itemsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text('No hay items en este catalogo.'),
                );
              }

              return ListView(
                children: [
                  for (final item in items)
                    DataCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nombre,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text('ID: ${item.id}'),
                              ],
                            ),
                          ),
                          if (isAdmin)
                            IconButton(
                              onPressed: () => _openEditSheet(item),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Editar',
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: DataCard(
                child: Text('No se pudo cargar catalogos. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditSheet(CatalogItem item) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.45,
        child: EditCatalogItemSheet(
          item: item,
          route: ref.read(activeCatalogProvider),
          onSaved: () => ref.invalidate(catalogItemsProvider),
        ),
      ),
    );
  }
}

class EditCatalogItemSheet extends ConsumerStatefulWidget {
  final CatalogItem item;
  final CatalogRoute route;
  final VoidCallback onSaved;

  const EditCatalogItemSheet({
    super.key,
    required this.item,
    required this.route,
    required this.onSaved,
  });

  @override
  ConsumerState<EditCatalogItemSheet> createState() =>
      _EditCatalogItemSheetState();
}

class _EditCatalogItemSheetState extends ConsumerState<EditCatalogItemSheet> {
  late final TextEditingController _nameCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.item.nombre);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar item de catalogo')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_error != null) ...[
            DataCard(child: Text(_error!)),
            const SizedBox(height: 8),
          ],
          Text(
            catalogRouteLabel(widget.route),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nombre'),
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
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();

    if (name.length < 2) {
      setState(() => _error = 'El nombre debe tener al menos 2 caracteres');
      return;
    }

    if (name.length > 100) {
      setState(() => _error = 'El nombre no puede exceder 100 caracteres');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final repository = ref.read(catalogosRepositoryProvider);
    final result = await repository.updateCatalogItem(
      widget.route,
      widget.item.id,
      name,
    );

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      widget.onSaved();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item actualizado correctamente')),
      );
      return;
    }

    setState(() {
      _saving = false;
      _error = result.failure?.message ?? 'No se pudo actualizar el item';
    });
  }
}
