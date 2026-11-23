import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/auth_repository.dart';
import '../../../features/auth/presentation/auth_controller.dart';
import '../../../shared/models/tipo_rol.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/page_header.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return Column(
      children: [
        const PageHeader(
          title: 'Mi sesion',
          subtitle: 'Datos actuales de autenticacion',
        ),
        DataCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuario: ${auth.user?.username ?? '-'}'),
              Text('Email: ${auth.user?.email ?? '-'}'),
              Text('Rol: ${tipoRolLabel(auth.user?.rol)}'),
              Text('Sucursal: ${auth.user?.sucursal ?? '-'}'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: FutureBuilder(
            future: ref.read(authRepositoryProvider).me(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final result = snapshot.data!;
              return DataCard(
                child: SingleChildScrollView(
                  child: Text(
                    result.isSuccess ? result.data.toString() : result.failure!.message,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
