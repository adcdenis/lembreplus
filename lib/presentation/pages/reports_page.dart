import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Relatórios', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Text('Gráficos e estatísticas (base).'),
        ],
      ),
    );
  }
}