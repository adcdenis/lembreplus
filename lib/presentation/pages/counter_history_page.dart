import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lembreplus/presentation/widgets/animated_button.dart';

class CounterHistoryPage extends ConsumerWidget {
  final int counterId;
  const CounterHistoryPage({super.key, required this.counterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyAsync = ref.watch(historyProvider(counterId));
    final countersRepo = ref.watch(counterRepositoryProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/counters');
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header melhorado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.primary.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.history_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Histórico',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      FutureBuilder(
                        future: countersRepo.byId(counterId),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const SizedBox(height: 16, child: LinearProgressIndicator());
                          }
                          final c = snap.data;
                          return Text(
                            c == null ? 'Contador #$counterId' : c.name,
                            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            historyAsync.when(
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Expanded(child: Center(child: Text('Erro ao carregar histórico: $e'))),
              data: (items) {
                if (items.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_toggle_off_rounded, size: 64, color: scheme.onSurface.withValues(alpha: 0.15)),
                          const SizedBox(height: 16),
                          Text(
                            'Sem histórico',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: scheme.onSurface.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'As alterações deste contador aparecerão aqui.',
                            style: TextStyle(fontSize: 13, color: scheme.onSurface.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final h = items[index];
                      final ts = DateFormat('dd/MM/yyyy HH:mm').format(h.timestamp);
                      final op = h.operation.toLowerCase();

                      // Ícone e cor baseados na operação
                      final IconData icon;
                      final Color iconColor;
                      final String opLabel;
                      switch (op) {
                        case 'create':
                          icon = Icons.add_circle_rounded;
                          iconColor = Colors.green;
                          opLabel = 'Criação';
                          break;
                        case 'update':
                          icon = Icons.edit_rounded;
                          iconColor = scheme.primary;
                          opLabel = 'Atualização';
                          break;
                        case 'delete':
                          icon = Icons.delete_rounded;
                          iconColor = scheme.error;
                          opLabel = 'Exclusão';
                          break;
                        default:
                          icon = Icons.info_outline;
                          iconColor = scheme.onSurfaceVariant;
                          opLabel = op;
                      }

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
                          _infoRow(Icons.label_outline, 'Nome', name, scheme),
                          if (description.trim().isNotEmpty) _infoRow(Icons.notes_outlined, 'Descrição', description, scheme),
                          _infoRow(Icons.local_offer_outlined, 'Categoria', category, scheme),
                          _infoRow(Icons.repeat_rounded, 'Recorrência', recurrence, scheme),
                          _infoRow(Icons.event_outlined, 'Evento', eventStr, scheme),
                          _infoRow(Icons.timer_outlined, prefix, '${years}a, ${months}m, ${days}d, ${hours}h, ${minutes}min, ${seconds}s', scheme),
                        ],
                      );
                    } catch (_) {
                      subtitleWidget = Text('Snapshot: ${h.snapshot}', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant));
                    }

                    final historyRepo = ref.watch(historyRepositoryProvider);

                    return AnimatedInteractiveItem(
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.2)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: ícone + operação + data + botão excluir
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(icon, size: 20, color: iconColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          opLabel,
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: iconColor),
                                        ),
                                        Text(
                                          ts,
                                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Excluir item do histórico',
                                    icon: Icon(Icons.delete_outline_rounded, size: 20, color: scheme.error),
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
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: scheme.outlineVariant.withValues(alpha: 0.2), height: 1),
                              const SizedBox(height: 10),
                              // Dados do snapshot
                              subtitleWidget,
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (15 * index).ms).slideX(begin: 0.1, end: 0);
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

  Widget _infoRow(IconData icon, String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface)),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}