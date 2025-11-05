import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/domain/recurrence.dart';

class CounterDetailPage extends ConsumerWidget {
  final int counterId;
  const CounterDetailPage({super.key, required this.counterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(counterRepositoryProvider);
    return FutureBuilder(
      future: repo.byId(counterId),
      builder: (context, snap) {
        final c = snap.data;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalhe do Contador', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              if (snap.connectionState != ConnectionState.done)
                const CircularProgressIndicator()
              else if (c == null)
                const Text('Contador não encontrado')
              else ...[
                Text('ID: ${c.id}'),
                const SizedBox(height: 8),
                Text('Nome: ${c.name}'),
                if (c.description != null) ...[
                  const SizedBox(height: 8),
                  Text('Descrição: ${c.description}')
                ],
                const SizedBox(height: 8),
                Text('Data: ${c.eventDate}'),
                const SizedBox(height: 8),
                Text('Categoria: ${c.category ?? '-'}'),
                const SizedBox(height: 8),
                () {
                  final rec = Recurrence.fromString(c.recurrence);
                  final label = () {
                    switch (rec) {
                      case Recurrence.none:
                        return 'Nenhuma';
                      case Recurrence.weekly:
                        return 'Semanal';
                      case Recurrence.monthly:
                        return 'Mensal';
                      case Recurrence.yearly:
                        return 'Anual';
                    }
                  }();
                  return Text('Recorrência: $label');
                }(),
                const SizedBox(height: 24),
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/counter/${c.id}/edit'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
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
                          context.go('/');
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                  ),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}