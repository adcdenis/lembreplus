import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lembreplus/state/providers.dart';

class CounterListPage extends ConsumerWidget {
  const CounterListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countersAsync = ref.watch(countersProvider);
    final repo = ref.watch(counterRepositoryProvider);

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
            const Text('Contadores', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            countersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erro ao carregar: $e'),
              data: (items) {
                if (items.isEmpty) {
                  return const Text('Nenhum contador cadastrado.');
                }
                return Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = items[index];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.description != null && c.description!.isNotEmpty)
                              Text(c.description!),
                            Text('Data: ${c.eventDate}')
                          ],
                        ),
                        onTap: () => context.go('/counter/${c.id}'),
                        trailing: Wrap(spacing: 8, children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit),
                            onPressed: () => context.go('/counter/${c.id}/edit'),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Excluir contador'),
                                  content: const Text('Tem certeza que deseja excluir? Esta ação não pode ser desfeita.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await repo.delete(c.id!);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contador excluído')));
                                }
                              }
                            },
                          ),
                        ]),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}