import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/counter/new'),
        icon: const Icon(Icons.add),
        label: const Text('Novo contador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('Bem-vindo ao Lembre+. Use o menu para navegar.'),
            const SizedBox(height: 24),
            Wrap(spacing: 12, runSpacing: 12, children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/counters'),
                icon: const Icon(Icons.list_alt),
                label: const Text('Contadores'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/summary'),
                icon: const Icon(Icons.summarize),
                label: const Text('Resumo'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/reports'),
                icon: const Icon(Icons.bar_chart),
                label: const Text('Relatórios'),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go('/backup'),
                icon: const Icon(Icons.backup),
                label: const Text('Backup'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}