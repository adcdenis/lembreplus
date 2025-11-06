import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lembreplus/state/providers.dart';

class CounterHistoryPage extends ConsumerWidget {
  final int counterId;
  const CounterHistoryPage({super.key, required this.counterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final historyAsync = ref.watch(historyProvider(counterId));
    final countersRepo = ref.watch(counterRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Histórico do contador', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          FutureBuilder(
            future: countersRepo.byId(counterId),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }
              final c = snap.data;
              return Text(
                c == null ? 'ID: $counterId' : 'ID: ${c.id} • ${c.name}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              );
            },
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Expanded(child: Center(child: Text('Erro ao carregar histórico: $e'))),
            data: (items) {
              if (items.isEmpty) {
                return const Expanded(child: Center(child: Text('Sem histórico para este contador.')));
              }

              return Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final h = items[index];
                    final ts = DateFormat('dd/MM/yyyy HH:mm').format(h.timestamp);
                    final op = h.operation.toLowerCase();
                    final icon = () {
                      switch (op) {
                        case 'create':
                          return Icons.add_circle_outline;
                        case 'update':
                          // Evita o ícone de "editar" para não sugerir ação de edição
                          return Icons.change_circle_outlined;
                        case 'delete':
                          return Icons.delete_outline;
                        default:
                          return Icons.info_outline;
                      }
                    }();

                    Widget subtitleWidget;
                    try {
                      final data = jsonDecode(h.snapshot) as Map<String, dynamic>;
                      final dir = (data['direction'] as String?) ?? '';
                      final prefix = dir == 'past' ? 'Passados' : 'Faltam';
                      final years = data['years'];
                      final months = data['months'];
                      final days = data['days'];
                      final hours = data['hours'];
                      final minutes = data['minutes'];
                      final seconds = data['seconds'];
                      final name = (data['name'] as String?) ?? '-';
                      final description = (data['description'] as String?) ?? '';
                      final category = (data['category'] as String?) ?? '-';
                      final recurrence = (data['recurrence'] as String?) ?? '-';
                      // Preferir componentes da data do evento para evitar erro de fuso horário
                      final eventDt = (() {
                        final ev = data['event'];
                        if (ev is Map) {
                          final ey = (ev['year'] as int?) ?? 0;
                          final em = (ev['month'] as int?) ?? 1;
                          final ed = (ev['day'] as int?) ?? 1;
                          final eh = (ev['hour'] as int?) ?? 0;
                          final emi = (ev['minute'] as int?) ?? 0;
                          final es = (ev['second'] as int?) ?? 0;
                          try {
                            return DateTime(ey, em, ed, eh, emi, es);
                          } catch (_) {/* fallthrough */}
                        }
                        final eventIso = (data['eventDate'] as String?) ?? '';
                        try {
                          final parsed = DateTime.parse(eventIso);
                          return parsed.isUtc ? parsed.toLocal() : parsed;
                        } catch (_) {
                          return null;
                        }
                      })();
                      final eventStr = eventDt != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(eventDt)
                          : '-';

                      subtitleWidget = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Nome: $name'),
                          if (description.trim().isNotEmpty) Text('Descrição: $description'),
                          Text('Categoria: $category'),
                          Text('Recorrência: $recurrence'),
                          Text('Evento: $eventStr'),
                          Text('$prefix: '
                              '${years}a, ${months}m, ${days}d, '
                              '${hours}h, ${minutes}min, ${seconds}s'),
                        ],
                      );
                    } catch (_) {
                      subtitleWidget = Text('Snapshot: ${h.snapshot}');
                    }

                    final historyRepo = ref.watch(historyRepositoryProvider);

                    return ListTile(
                      leading: Icon(icon, color: scheme.primary),
                      title: Text(op == 'create' ? 'Criação em $ts' : op == 'update' ? 'Atualização em $ts' : '$op em $ts'),
                      subtitle: subtitleWidget,
                      dense: true,
                      trailing: IconButton.filledTonal(
                        tooltip: 'Excluir item do histórico',
                        icon: const Text('🗑️', style: TextStyle(fontSize: 20)),
                        onPressed: () async {
                          if (h.id == null) return;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Excluir histórico'),
                              content: const Text('Deseja excluir este item do histórico?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await historyRepo.delete(h.id!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Item do histórico excluído')),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}