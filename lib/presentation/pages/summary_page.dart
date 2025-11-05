import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Resumo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Text('Visão geral dos contadores e categorias (base).'),
        ],
      ),
    );
  }
}