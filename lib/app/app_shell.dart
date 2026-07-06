import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../shared/models/tipo_rol.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/activos/presentation/activos_page.dart';
import '../features/clientes/presentation/clientes_page.dart';
import '../features/pdvs/presentation/pdvs_page.dart';
import '../features/catalogos/presentation/catalogos_page.dart';
import '../features/asignaciones/presentation/asignaciones_page.dart';
import '../features/bitacora/presentation/bitacora_page.dart';
import '../features/usuarios/presentation/usuarios_page.dart';
import '../features/me/presentation/me_page.dart';
import '../features/tickets/presentation/tickets_page.dart';
import '../features/reportes/presentation/reportes_page.dart';

final selectedModuleProvider = StateProvider<String>((ref) => 'dashboard');

class _ModuleItem {
  final String keyName;
  final String label;
  const _ModuleItem(this.keyName, this.label);
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedModuleProvider);
    final auth = ref.watch(authControllerProvider);

    Widget page;
    switch (selected) {
      case 'activos':
        page = const ActivosPage();
        break;
      case 'clientes':
        page = const ClientesPage();
        break;
      case 'pdvs':
        page = const PdvsPage();
        break;
      case 'catalogos':
        page = const CatalogosPage();
        break;
      case 'asignaciones':
        page = const AsignacionesPage();
        break;
      case 'bitacora':
        page = const BitacoraPage();
        break;
      case 'usuarios':
        page = const UsuariosPage();
        break;
      case 'me':
        page = const MePage();
        break;
      case 'tickets':
        page = const TicketsPage();
        break;
      case 'reportes':
        page = const ReportesPage();
        break;
      default:
        page = const DashboardPage();
    }

    final rol = auth.user?.rol;
    final modules = <_ModuleItem>[
      const _ModuleItem('dashboard', 'Dashboard'),
      const _ModuleItem('activos', 'Activos'),
      const _ModuleItem('clientes', 'Clientes'),
      const _ModuleItem('pdvs', 'PDVs'),
      const _ModuleItem('catalogos', 'Catalogos'),
      const _ModuleItem('asignaciones', 'Asignaciones'),
      if (rol == TipoRol.autorizador || rol == TipoRol.administrador)
        const _ModuleItem('bitacora', 'Bitacora'),
      if (rol == TipoRol.administrador)
        const _ModuleItem('usuarios', 'Usuarios'),
      const _ModuleItem('me', 'Mi sesion'),
      const _ModuleItem('tickets', 'Tickets'),
      const _ModuleItem('reportes', 'Reportes'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('SistemaEF Mobile'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mesa de servicio'),
                  const SizedBox(height: 8),
                  Text(auth.user?.username ?? '-'),
                ],
              ),
            ),
            for (final module in modules)
              ListTile(
                selected: selected == module.keyName,
                title: Text(module.label),
                onTap: () {
                  ref.read(selectedModuleProvider.notifier).state =
                      module.keyName;
                  Navigator.of(context).pop();
                },
              )
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(12), child: page),
      ),
    );
  }
}
