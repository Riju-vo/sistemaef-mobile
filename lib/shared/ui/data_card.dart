import 'package:flutter/material.dart';

class DataCard extends StatelessWidget {
  final Widget child;
  const DataCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}