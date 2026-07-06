import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChange;

  const PaginationControls({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final safePage = page < 1 ? 1 : page;
    final safeTotalPages = totalPages < 1 ? 1 : totalPages;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: safePage > 1 ? () => onPageChange(safePage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Anterior'),
          ),
          const Spacer(),
          Text('Pagina $safePage de $safeTotalPages'),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: safePage < safeTotalPages
                ? () => onPageChange(safePage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }
}
