import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/counter/new'),
        child: const Icon(Icons.add),
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
              FilledButton.icon(
                onPressed: () => context.go('/counters'),
                icon: const Text('🧮', style: TextStyle(fontSize: 20)),
                label: const Text('Contadores'),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/summary'),
                icon: const Text('📊', style: TextStyle(fontSize: 20)),
                label: const Text('Resumo'),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/reports'),
                icon: const Text('📈', style: TextStyle(fontSize: 20)),
                label: const Text('Relatórios'),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/backup'),
                icon: const Text('🔄', style: TextStyle(fontSize: 20)),
                label: const Text('Backup'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}