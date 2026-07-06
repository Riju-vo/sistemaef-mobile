import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme.dart';
import '../../../core/network/dio_provider.dart';
import '../../../features/auth/domain/auth_models.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/pagination_controls.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/ui/status_badge.dart';
import '../data/tickets_repository.dart';
import '../domain/ticket_models.dart';
import 'tickets_controller.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(ticketsQueryProvider);
    final ticketsAsync = ref.watch(ticketsListProvider);
    final auth = ref.watch(authControllerProvider);
    final canCreate = _canCreateTicket(auth.user?.rol);

    return Column(
      children: [
        PageHeader(
          title: 'Tickets',
          subtitle: 'Mesa de servicio conectada al backend actual',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canCreate)
                IconButton(
                  onPressed: () => _openCreateTicket(context),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Crear ticket',
                ),
              IconButton(
                onPressed: () => ref.refresh(ticketsListProvider),
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
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por activo, serial, cliente o PDV',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(ticketsQueryProvider.notifier).state =
                          query.copyWith(
                        page: 1,
                        search: '',
                      );
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  ref.read(ticketsQueryProvider.notifier).state =
                      query.copyWith(
                    page: 1,
                    search: value.trim(),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TicketEstado?>(
                      isExpanded: true,
                      value: query.estado,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: [
                        const DropdownMenuItem<TicketEstado?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...TicketEstado.values.map(
                          (estado) => DropdownMenuItem<TicketEstado?>(
                            value: estado,
                            child: Text(
                              ticketEstadoLabel(estado),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(ticketsQueryProvider.notifier).state =
                            value == null
                                ? query.copyWith(page: 1, clearEstado: true)
                                : query.copyWith(page: 1, estado: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      isExpanded: true,
                      value: query.tipoServicio,
                      decoration: const InputDecoration(
                        labelText: 'Tipo servicio',
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...allTicketServiceOptions.map(
                          (tipo) => DropdownMenuItem<String?>(
                            value: tipo,
                            child: Text(
                              formatTicketTipoServicio(tipo),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(ticketsQueryProvider.notifier).state = value ==
                                null
                            ? query.copyWith(page: 1, clearTipoServicio: true)
                            : query.copyWith(page: 1, tipoServicio: value);
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
                      value: query.emergencia,
                      decoration: const InputDecoration(
                        labelText: 'Emergencia',
                      ),
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Solo emergencia'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Solo no emergencia'),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(ticketsQueryProvider.notifier).state =
                            value == null
                                ? query.copyWith(page: 1, clearEmergencia: true)
                                : query.copyWith(page: 1, emergencia: value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      value: query.soloMios,
                      onChanged: (value) {
                        ref.read(ticketsQueryProvider.notifier).state =
                            query.copyWith(
                          page: 1,
                          soloMios: value,
                        );
                      },
                      title: const Text('Solo mios'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(ticketsQueryProvider.notifier).state =
                        const TicketsQuery();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ticketsAsync.when(
            data: (response) {
              if (response.data.isEmpty) {
                return const Center(
                  child: Text('No hay tickets para los filtros actuales.'),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(ticketsListProvider);
                  await ref.read(ticketsListProvider.future);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Mostrando ${response.data.length} de ${response.meta.total} tickets',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final item in response.data)
                      _TicketCard(
                        item: item,
                        onTap: () => _openTicketDetail(context, item.idTicket),
                      ),
                    PaginationControls(
                      page: response.meta.page,
                      totalPages: response.meta.totalPages,
                      onPageChange: (page) {
                        ref.read(ticketsQueryProvider.notifier).state =
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
                child: Text('No se pudo cargar tickets. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openTicketDetail(BuildContext context, String ticketId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: TicketDetailSheet(ticketId: ticketId),
      ),
    );
  }

  Future<void> _openCreateTicket(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.95,
        child: CreateTicketSheet(
          onCreated: () {
            ref.invalidate(ticketsListProvider);
          },
        ),
      ),
    );
  }

  bool _canCreateTicket(TipoRol? rol) {
    return rol == TipoRol.registrador ||
        rol == TipoRol.administrador ||
        rol == TipoRol.tecnicoInterno;
  }
}

class _TicketCard extends StatelessWidget {
  final TicketItem item;
  final VoidCallback onTap;

  const _TicketCard({
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
                    'Ticket #${item.idTicket}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
                const SizedBox(width: 8),
                StatusBadge(
                  label: ticketEstadoLabel(item.estado),
                  color: _statusColor(item.estado),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Activo: ${item.activo.etiqueta}'),
            Text('Cliente: ${item.cliente.nombre}'),
            Text('PDV: ${item.pdv?.nombreNegocio ?? 'Sin PDV'}'),
            Text('Servicio: ${formatTicketTipoServicio(item.tipoServicio)}'),
            Text('Estado equipo: ${item.activo.estadoEquipo}'),
            Text('Registrador: ${item.registrador.username}'),
            if (item.responsableEjecucion != null)
              Text('Responsable: ${item.responsableEjecucion!.username}'),
            if (item.comentarioRegistrador != null &&
                item.comentarioRegistrador!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.comentarioRegistrador!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (item.emergencia) ...[
              const SizedBox(height: 8),
              const StatusBadge(
                label: 'Emergencia',
                color: AppColors.danger,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(TicketEstado estado) {
    switch (estado) {
      case TicketEstado.pendienteAprobacion:
        return Colors.orange;
      case TicketEstado.aprobado:
        return AppColors.primary;
      case TicketEstado.enAtencion:
        return Colors.deepPurple;
      case TicketEstado.concluido:
        return AppColors.success;
      case TicketEstado.inconcluso:
        return Colors.brown;
      case TicketEstado.rechazado:
        return AppColors.danger;
    }
  }
}

class TicketDetailSheet extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailSheet({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailSheet> createState() => _TicketDetailSheetState();
}

class _TicketDetailSheetState extends ConsumerState<TicketDetailSheet> {
  bool _isStarting = false;
  bool _isClosing = false;
  bool _isDeciding = false;
  String? _actionError;
  final _observacionCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  TicketResponsableTipo? _responsableTipo;
  String? _responsableId;

  @override
  void dispose() {
    _observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${widget.ticketId}'),
      ),
      body: detailAsync.when(
        data: (ticket) {
          final canExecute = _canExecuteTicket(ticket, auth.user);
          final canAuthorize = _canAuthorizeTicket(auth.user?.rol);
          final responsablesFuture = _responsableTipo == null
              ? null
              : ref
                  .read(ticketsRepositoryProvider)
                  .listResponsables(_responsableTipo!);

          if (_observacionCtrl.text.isEmpty &&
              (ticket.observacionAutorizador ?? '').trim().isNotEmpty) {
            _observacionCtrl.text = ticket.observacionAutorizador!;
          }
          _responsableTipo ??= ticket.tipoResponsableEjecucion;
          _responsableId ??= ticket.responsableEjecucion?.idUsuario;

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
                            formatTicketTipoServicio(ticket.tipoServicio),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusBadge(
                          label: ticketEstadoLabel(ticket.estado),
                          color: _statusColor(ticket.estado),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (ticket.emergencia)
                          const StatusBadge(
                            label: 'Emergencia',
                            color: AppColors.danger,
                          ),
                        if (ticket.tipoResponsableEjecucion != null)
                          StatusBadge(
                            label: _responsableLabel(
                                ticket.tipoResponsableEjecucion),
                            color: AppColors.muted,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DetailLine(label: 'Activo', value: ticket.activo.etiqueta),
                    _DetailLine(
                      label: 'Descripcion equipo',
                      value: ticket.activo.descripcionEquipo,
                    ),
                    _DetailLine(
                      label: 'Estado equipo',
                      value: ticket.activo.estadoEquipo,
                    ),
                    _DetailLine(label: 'Cliente', value: ticket.cliente.nombre),
                    _DetailLine(
                      label: 'PDV',
                      value: ticket.pdv?.nombreNegocio ?? 'Sin PDV',
                    ),
                    _DetailLine(
                      label: 'Registrador',
                      value: ticket.registrador.username,
                    ),
                    _DetailLine(
                      label: 'Responsable',
                      value: ticket.responsableEjecucion?.username ??
                          'Sin asignar',
                    ),
                    _DetailLine(
                      label: 'Fecha creacion',
                      value: _formatDateTime(ticket.fechaCreacion),
                    ),
                    _DetailLine(
                      label: 'Fecha inicio atencion',
                      value: _formatDateTime(ticket.fechaInicioAtencion),
                    ),
                    _DetailLine(
                      label: 'Fecha cierre',
                      value: _formatDateTime(ticket.fechaCierre),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              DataCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comentario del registrador',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.comentarioRegistrador ?? 'Sin comentario'),
                    if ((ticket.observacionAutorizador ?? '')
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Observacion del autorizador',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(ticket.observacionAutorizador!),
                    ],
                    if ((ticket.comentarioCierre ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Comentario de cierre',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(ticket.comentarioCierre!),
                    ],
                    if ((ticket.evidenciaCierreUrl ?? '')
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Evidencia del cierre',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _resolveApiUrl(ticket.evidenciaCierreUrl!),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Text(
                            'No se pudo cargar la evidencia adjunta.',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_actionError != null) ...[
                const SizedBox(height: 8),
                DataCard(child: Text(_actionError!)),
              ],
              if (canAuthorize &&
                  ticket.estado == TicketEstado.pendienteAprobacion) ...[
                const SizedBox(height: 8),
                DataCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Decision del autorizador',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _observacionCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Observacion del autorizador',
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TicketResponsableTipo?>(
                        value: _responsableTipo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de ejecutor',
                        ),
                        items: [
                          const DropdownMenuItem<TicketResponsableTipo?>(
                            value: null,
                            child: Text('Selecciona un tipo'),
                          ),
                          ...TicketResponsableTipo.values.map(
                            (tipo) => DropdownMenuItem<TicketResponsableTipo?>(
                              value: tipo,
                              child: Text(responsableTipoLabel(tipo)),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _responsableTipo = value;
                            _responsableId = null;
                          });
                        },
                      ),
                      if (_responsableTipo != null) ...[
                        const SizedBox(height: 12),
                        FutureBuilder(
                          future: responsablesFuture,
                          builder: (context, snapshot) {
                            final result = snapshot.data;
                            final responsables = result != null &&
                                    result.isSuccess &&
                                    result.data != null
                                ? result.data!
                                : <TicketUsuario>[];

                            return DropdownButtonFormField<String?>(
                              value: _responsableId,
                              decoration: const InputDecoration(
                                labelText: 'Responsable de ejecucion',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Selecciona un responsable'),
                                ),
                                ...responsables.map(
                                  (item) => DropdownMenuItem<String?>(
                                    value: item.idUsuario,
                                    child: Text(
                                      item.email.isNotEmpty
                                          ? '${item.username} (${item.email})'
                                          : item.username,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? null
                                  : (value) {
                                      setState(() => _responsableId = value);
                                    },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isDeciding
                                  ? null
                                  : () => _decidirTicket(
                                        ticketId: ticket.idTicket,
                                        decision: 'RECHAZAR',
                                      ),
                              child: Text(
                                _isDeciding ? 'Procesando...' : 'Rechazar',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isDeciding
                                  ? null
                                  : () => _decidirTicket(
                                        ticketId: ticket.idTicket,
                                        decision: 'APROBAR',
                                      ),
                              child: Text(
                                _isDeciding ? 'Procesando...' : 'Aprobar',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (canExecute && ticket.estado == TicketEstado.aprobado) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _isStarting
                      ? null
                      : () => _iniciarAtencion(ticket.idTicket),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    _isStarting ? 'Iniciando...' : 'Iniciar atencion',
                  ),
                ),
              ],
              if (canExecute && ticket.estado == TicketEstado.enAtencion) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _isClosing
                      ? null
                      : () => _abrirDialogoCerrar(ticket.idTicket),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isClosing ? 'Cerrando...' : 'Cerrar ticket',
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: DataCard(
            child: Text('No se pudo cargar el detalle. $error'),
          ),
        ),
      ),
    );
  }

  bool _canExecuteTicket(TicketItem ticket, AuthUser? user) {
    final rol = user?.rol;
    final userId = user?.id;
    if (rol == TipoRol.administrador) return true;
    final isExecutorRole =
        rol == TipoRol.tecnicoInterno || rol == TipoRol.proveedor;
    if (!isExecutorRole || userId == null) return false;
    return ticket.responsableEjecucion?.idUsuario == userId;
  }

  bool _canAuthorizeTicket(TipoRol? rol) {
    return rol == TipoRol.autorizador || rol == TipoRol.administrador;
  }

  Future<void> _decidirTicket({
    required String ticketId,
    required String decision,
  }) async {
    final observacion = _observacionCtrl.text.trim();
    if (observacion.isEmpty) {
      setState(() {
        _actionError = 'La observacion del autorizador es obligatoria';
      });
      return;
    }

    if (decision == 'APROBAR') {
      if (_responsableTipo == null) {
        setState(() {
          _actionError = 'Debes seleccionar un tipo de ejecutor';
        });
        return;
      }
      if (_responsableId == null || _responsableId!.trim().isEmpty) {
        setState(() {
          _actionError = 'Debes seleccionar un responsable de ejecucion';
        });
        return;
      }
    }

    setState(() {
      _isDeciding = true;
      _actionError = null;
    });

    final result = await ref.read(ticketsRepositoryProvider).decidirTicket(
          id: ticketId,
          decision: decision,
          observacionAutorizador: observacion,
          tipoResponsable: decision == 'APROBAR' ? _responsableTipo : null,
          idResponsableEjecucion: decision == 'APROBAR' ? _responsableId : null,
        );

    if (!mounted) return;

    setState(() {
      _isDeciding = false;
      _actionError = result.isSuccess ? null : result.failure?.message;
    });

    if (result.isSuccess) {
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(ticketsListProvider);
    }
  }

  Future<void> _iniciarAtencion(String ticketId) async {
    setState(() {
      _isStarting = true;
      _actionError = null;
    });

    final result =
        await ref.read(ticketsRepositoryProvider).iniciarAtencion(ticketId);

    if (!mounted) return;

    setState(() {
      _isStarting = false;
      _actionError = result.isSuccess ? null : result.failure?.message;
    });

    if (result.isSuccess) {
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(ticketsListProvider);
    }
  }

  Future<void> _abrirDialogoCerrar(String ticketId) async {
    final formKey = GlobalKey<FormState>();
    String resultado = 'CONCLUIDO';
    final comentarioCtrl = TextEditingController();
    XFile? evidenciaCierre;
    String? evidenciaError;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Cerrar ticket'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: resultado,
                        decoration:
                            const InputDecoration(labelText: 'Resultado'),
                        items: const [
                          DropdownMenuItem(
                            value: 'CONCLUIDO',
                            child: Text('Concluido'),
                          ),
                          DropdownMenuItem(
                            value: 'INCONCLUSO',
                            child: Text('Inconcluso'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setLocalState(() => resultado = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            final picked = await _imagePicker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 85,
                              maxWidth: 1600,
                            );

                            if (picked == null) return;
                            setLocalState(() {
                              evidenciaCierre = picked;
                              evidenciaError = null;
                            });
                          },
                          icon: const Icon(Icons.photo_camera_outlined),
                          label: Text(
                            evidenciaCierre == null
                                ? 'Tomar foto obligatoria'
                                : 'Volver a tomar foto',
                          ),
                        ),
                      ),
                      if (evidenciaError != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            evidenciaError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                      if (evidenciaCierre != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(evidenciaCierre!.path),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: comentarioCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Comentario de cierre',
                        ),
                        validator: (value) {
                          if (resultado == 'INCONCLUSO' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'El comentario es obligatorio para inconcluso';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) return;
                    if (evidenciaCierre == null) {
                      setLocalState(() {
                        evidenciaError =
                            'Debes tomar una foto como evidencia del servicio';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) {
      comentarioCtrl.dispose();
      return;
    }

    setState(() {
      _isClosing = true;
      _actionError = null;
    });

    final result = await ref.read(ticketsRepositoryProvider).cerrarTicket(
          id: ticketId,
          resultado: resultado,
          evidenciaCierrePath: evidenciaCierre!.path,
          comentarioCierre: comentarioCtrl.text,
        );

    comentarioCtrl.dispose();

    if (!mounted) return;

    setState(() {
      _isClosing = false;
      _actionError = result.isSuccess ? null : result.failure?.message;
    });

    if (result.isSuccess) {
      ref.invalidate(ticketDetailProvider(ticketId));
      ref.invalidate(ticketsListProvider);
    }
  }

  String _formatDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  String _resolveApiUrl(String path) {
    final baseUrl = ref.read(dioProvider).options.baseUrl;
    return Uri.parse(baseUrl).resolve(path).toString();
  }

  String _responsableLabel(TicketResponsableTipo? value) {
    switch (value) {
      case TicketResponsableTipo.tecnicoInterno:
        return responsableTipoLabel(TicketResponsableTipo.tecnicoInterno);
      case TicketResponsableTipo.proveedor:
        return responsableTipoLabel(TicketResponsableTipo.proveedor);
      default:
        return 'Sin responsable';
    }
  }

  Color _statusColor(TicketEstado estado) {
    switch (estado) {
      case TicketEstado.pendienteAprobacion:
        return Colors.orange;
      case TicketEstado.aprobado:
        return AppColors.primary;
      case TicketEstado.enAtencion:
        return Colors.deepPurple;
      case TicketEstado.concluido:
        return AppColors.success;
      case TicketEstado.inconcluso:
        return Colors.brown;
      case TicketEstado.rechazado:
        return AppColors.danger;
    }
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

class CreateTicketSheet extends ConsumerStatefulWidget {
  final VoidCallback onCreated;

  const CreateTicketSheet({
    super.key,
    required this.onCreated,
  });

  @override
  ConsumerState<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends ConsumerState<CreateTicketSheet> {
  final _commentCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _tipoServicio = activeTicketServiceOptions.first;
  bool _emergencia = false;
  bool _soloDisponibles = true;
  bool _isCreating = false;
  String? _error;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear ticket'),
      ),
      body: FutureBuilder(
        future: ref.read(ticketsRepositoryProvider).listCandidatos(
              search: _search,
              soloDisponibles: _soloDisponibles,
              page: 1,
              limit: 20,
            ),
        builder: (context, snapshot) {
          final result = snapshot.data;
          final candidatos =
              result != null && result.isSuccess && result.data != null
                  ? result.data!.data
                  : <TicketCandidato>[];

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              DataCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        labelText:
                            'Buscar candidato por activo, serial, cliente o PDV',
                        suffixIcon: IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      onSubmitted: (value) {
                        setState(() => _search = value.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tipoServicio,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de servicio',
                      ),
                      items: activeTicketServiceOptions
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(formatTicketTipoServicio(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _tipoServicio = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _emergencia,
                      onChanged: (value) => setState(() => _emergencia = value),
                      title: const Text('Emergencia'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      value: _soloDisponibles,
                      onChanged: (value) =>
                          setState(() => _soloDisponibles = value),
                      title: const Text('Solo disponibles'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Comentario del registrador',
                      ),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                DataCard(child: Text(_error!)),
              ],
              const SizedBox(height: 8),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (result == null || !result.isSuccess)
                const DataCard(
                  child:
                      Text('No se pudo cargar candidatos para crear ticket.'),
                )
              else if (candidatos.isEmpty)
                const DataCard(
                  child:
                      Text('No hay candidatos disponibles con esos filtros.'),
                )
              else
                for (final candidate in candidatos)
                  DataCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.etiqueta,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text('Cliente: ${candidate.nombreCliente}'),
                        Text('PDV: ${candidate.nombrePdv ?? 'Sin PDV'}'),
                        Text('Equipo: ${candidate.descripcionEquipo}'),
                        Text('Estado: ${candidate.estadoEquipo}'),
                        if (candidate.bloqueadoPorTicketAbierto)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: StatusBadge(
                              label:
                                  'Bloqueado por ticket ${candidate.ticketAbiertoId ?? ''}',
                              color: AppColors.danger,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: candidate.bloqueadoPorTicketAbierto ||
                                    _isCreating
                                ? null
                                : () => _createTicket(candidate),
                            child: Text(
                              _isCreating ? 'Creando...' : 'Crear ticket',
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

  Future<void> _createTicket(TicketCandidato candidate) async {
    if (_commentCtrl.text.trim().isEmpty) {
      setState(() {
        _error = 'El comentario del registrador es obligatorio';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _error = null;
    });

    final result = await ref.read(ticketsRepositoryProvider).createTicket(
          idActivo: candidate.idActivo,
          tipoServicio: _tipoServicio,
          emergencia: _emergencia,
          comentarioRegistrador: _commentCtrl.text,
        );

    if (!mounted) return;

    setState(() {
      _isCreating = false;
      _error = result.isSuccess ? null : result.failure?.message;
    });

    if (result.isSuccess) {
      widget.onCreated();
      Navigator.of(context).pop();
    }
  }
}
