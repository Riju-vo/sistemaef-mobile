import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/ui/status_badge.dart';
import '../data/usuarios_repository.dart';
import '../domain/usuario_models.dart';
import 'usuarios_controller.dart';

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    if (auth.user?.rol != TipoRol.administrador) {
      return const Column(
        children: [
          PageHeader(
            title: 'Usuarios',
            subtitle: 'Gestion administrativa de accesos del sistema',
          ),
          DataCard(
            child: Text(
              'Este modulo solo esta disponible para usuarios con rol Administrador.',
            ),
          ),
        ],
      );
    }

    final query = ref.watch(usuariosQueryProvider);
    final usuariosAsync = ref.watch(usuariosListProvider);

    return Column(
      children: [
        PageHeader(
          title: 'Usuarios',
          subtitle: 'Gestion administrativa de credenciales y roles',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _openUsuarioForm(context),
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Crear usuario',
              ),
              IconButton(
                onPressed: () => ref.refresh(usuariosListProvider),
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar',
              ),
            ],
          ),
        ),
        FutureBuilder<List<RolOption>>(
          future: _loadRoles(),
          builder: (context, snapshot) {
            final roles = snapshot.data ?? const <RolOption>[];

            return DataCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          onSubmitted: (value) {
                            ref.read(usuariosQueryProvider.notifier).state =
                                query.copyWith(page: 1, username: value.trim());
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Correo'),
                          onSubmitted: (value) {
                            ref.read(usuariosQueryProvider.notifier).state =
                                query.copyWith(page: 1, email: value.trim());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          isExpanded: true,
                          value: query.tipoRol,
                          decoration: const InputDecoration(labelText: 'Rol'),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ...roles.map(
                              (rol) => DropdownMenuItem<int?>(
                                value: rol.id,
                                child: Text(rol.nombre),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            ref.read(usuariosQueryProvider.notifier).state =
                                value == null
                                    ? query.copyWith(
                                        page: 1, clearTipoRol: true)
                                    : query.copyWith(page: 1, tipoRol: value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<bool?>(
                          isExpanded: true,
                          value: query.activo,
                          decoration:
                              const InputDecoration(labelText: 'Activo'),
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
                            ref.read(usuariosQueryProvider.notifier).state =
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
                        _usernameCtrl.clear();
                        _emailCtrl.clear();
                        ref.read(usuariosQueryProvider.notifier).state =
                            const UsuariosQuery();
                      },
                      child: const Text('Limpiar filtros'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: usuariosAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay usuarios para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(usuariosListProvider);
                  await ref.read(usuariosListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} usuarios',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data)
                      _UsuarioCard(
                        item: item,
                        onEdit: () => _openUsuarioForm(context, item: item),
                        onDeactivate: item.activo
                            ? () => _confirmDeactivate(context, item)
                            : null,
                      ),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(usuariosQueryProvider.notifier).state =
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
                child: Text('No se pudo cargar usuarios. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<RolOption>> _loadRoles() async {
    final repository = ref.read(usuariosRepositoryProvider);
    final result = await repository.listRoles();
    return result.data ?? <RolOption>[];
  }

  Future<void> _openUsuarioForm(
    BuildContext context, {
    UsuarioItem? item,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: UsuarioFormSheet(
          item: item,
          onSaved: () => ref.invalidate(usuariosListProvider),
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    UsuarioItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar usuario'),
        content: Text('Se desactivara ${item.username}.'),
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
    final repository = ref.read(usuariosRepositoryProvider);
    final result = await repository.removeUsuario(item.idUsuario);

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ref.invalidate(usuariosListProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuario desactivado')),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.failure?.message ?? 'No se pudo desactivar el usuario',
        ),
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final UsuarioItem item;
  final VoidCallback onEdit;
  final VoidCallback? onDeactivate;

  const _UsuarioCard({
    required this.item,
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
                  item.username,
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
          Text('Correo: ${item.email}'),
          Text('Rol: ${item.rol ?? 'Sin rol'}'),
          Text('Creado: ${_formatDate(item.createdAt)}'),
          Text('Ultima actividad: ${_formatDate(item.lastActive)}'),
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
      ),
    );
  }
}

class UsuarioFormSheet extends ConsumerStatefulWidget {
  final UsuarioItem? item;
  final VoidCallback onSaved;

  const UsuarioFormSheet({
    super.key,
    required this.item,
    required this.onSaved,
  });

  @override
  ConsumerState<UsuarioFormSheet> createState() => _UsuarioFormSheetState();
}

class _UsuarioFormSheetState extends ConsumerState<UsuarioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passwordCtrl;
  int? _selectedRol;
  bool _clearRol = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _usernameCtrl = TextEditingController(text: item?.username ?? '');
    _emailCtrl = TextEditingController(text: item?.email ?? '');
    _passwordCtrl = TextEditingController();
    _selectedRol = item?.tipoRol;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar usuario' : 'Crear usuario'),
      ),
      body: FutureBuilder<List<RolOption>>(
        future: _loadRoles(),
        builder: (context, snapshot) {
          final roles = snapshot.data ?? const <RolOption>[];

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
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.length < 3) {
                          return 'Username requerido';
                        }
                        if (text.length > 80) {
                          return 'No puede exceder 80 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) {
                          return 'Correo requerido';
                        }
                        if (text.length > 150) {
                          return 'No puede exceder 150 caracteres';
                        }
                        final emailRegex = RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        );
                        if (!emailRegex.hasMatch(text)) {
                          return 'Correo invalido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? 'Password (opcional para actualizar)'
                            : 'Password',
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (!isEditing && text.isEmpty) {
                          return 'La password es obligatoria al crear';
                        }
                        if (text.isNotEmpty && text.length < 8) {
                          return 'Debe tener al menos 8 caracteres';
                        }
                        if (text.length > 255) {
                          return 'No puede exceder 255 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      value: _selectedRol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Sin rol'),
                        ),
                        ...roles.map(
                          (rol) => DropdownMenuItem<int?>(
                            value: rol.id,
                            child: Text(rol.nombre),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRol = value;
                          _clearRol = value == null;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: Text(
                          _saving ? 'Guardando...' : 'Guardar usuario',
                        ),
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

  Future<List<RolOption>> _loadRoles() async {
    final repository = ref.read(usuariosRepositoryProvider);
    final result = await repository.listRoles();
    return result.data ?? <RolOption>[];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final repository = ref.read(usuariosRepositoryProvider);
    final result = widget.item == null
        ? await repository.createUsuario(
            UsuarioCreatePayload(
              username: _usernameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text.trim(),
              tipoRol: _selectedRol,
            ),
          )
        : await repository.updateUsuario(
            widget.item!.idUsuario,
            UsuarioUpdatePayload(
              username: _usernameCtrl.text.trim(),
              email: _emailCtrl.text.trim(),
              password: _passwordCtrl.text.trim(),
              tipoRol: _selectedRol,
              clearTipoRol: _clearRol,
            ),
          );

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
                ? 'Usuario creado correctamente'
                : 'Usuario actualizado correctamente',
          ),
        ),
      );
      return;
    }

    setState(() {
      _saving = false;
      _error = result.failure?.message ?? 'No se pudo guardar el usuario';
    });
  }
}

String _formatDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }

  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(parsed.day)}/${two(parsed.month)}/${parsed.year} ${two(parsed.hour)}:${two(parsed.minute)}';
}
