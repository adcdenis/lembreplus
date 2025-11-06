import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Text('📈', style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Text('Relatórios', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          const Text('Gráficos e estatísticas (base).'),
        ],
      ),
    );
  }
}