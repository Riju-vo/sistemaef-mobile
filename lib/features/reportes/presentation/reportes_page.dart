import 'package:flutter/material.dart';
import '../../../shared/ui/data_card.dart';
import '../../../shared/ui/page_header.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PageHeader(title: 'Reportes', subtitle: 'Disponible en una siguiente fase'),
        DataCard(child: Text('Proximamente se habilitaran metricas y reportes operativos.')),
      ],
    );
  }
}