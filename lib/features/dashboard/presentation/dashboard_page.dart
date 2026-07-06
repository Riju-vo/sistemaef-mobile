import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/page_header.dart';
import '../../../shared/utils/module_api.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<int> _count(WidgetRef ref, String endpoint) async {
    return ref.read(moduleApiProvider).total(
          endpoint,
          query: const {'page': 1, 'limit': 1},
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const PageHeader(
          title: 'Dashboard',
          subtitle: 'Resumen operativo del sistema',
        ),
        Expanded(
          child: FutureBuilder<List<int>>(
            future: Future.wait([
              _count(ref, '/activos'),
              _count(ref, '/clientes'),
              _count(ref, '/pdvs'),
              _count(ref, '/catalogos/tipos-activo'),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final values = snapshot.data!;
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.8,
                children: [
                  _stat('Activos', values[0]),
                  _stat('Clientes', values[1]),
                  _stat('PDVs', values[2]),
                  _stat('Tipos Activo', values[3]),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _stat(String title, int value) {
    return DataCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const Spacer(),
          Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
