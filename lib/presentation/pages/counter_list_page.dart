import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';

class CounterListPage extends ConsumerStatefulWidget {
  const CounterListPage({super.key});

  @override
  ConsumerState<CounterListPage> createState() => _CounterListPageState();
}

class _CounterListPageState extends ConsumerState<CounterListPage> {
  String _labelForRecurrence(Recurrence r) {
    switch (r) {
      case Recurrence.none:
        return 'Nenhuma';
      case Recurrence.weekly:
        return 'Semanal';
      case Recurrence.monthly:
        return 'Mensal';
      case Recurrence.yearly:
        return 'Anual';
    }
  }
  
  TimeDiffComponents _calendarComponents(DateTime a, DateTime b) {
    // Usa diferença de calendário normalizada em horário local
    return calendarDiff(a, b);
  }
  String _search = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final countersAsync = ref.watch(countersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
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
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar por descrição ou nome...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              countersAsync.when(
                loading: () => const SizedBox(width: 200, height: 48, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => const SizedBox(),
                data: (items) {
                  // Conjunta categorias presentes nos contadores
                  final presentCats = <String>{
                    for (final c in items)
                      if ((c.category ?? '').trim().isNotEmpty) (c.category!)
                  };

                  // Map de nomes amigáveis se existirem no provider de categorias
                  final catsData = categoriesAsync.asData?.value ?? const [];
                  final nameByNormalized = {
                    for (final cat in catsData) cat.normalized: cat.name,
                  };

                  final dropdownItems = <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(value: null, child: Text('Todas as categorias')),
                    ...presentCats.map((norm) => DropdownMenuItem<String?>(
                          value: norm,
                          child: Text(nameByNormalized[norm] ?? norm),
                        )),
                  ];

                  return SizedBox(
                    width: 240,
                    height: 48,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: dropdownItems,
                          onChanged: (v) => setState(() => _selectedCategory = v),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),
            countersAsync.when(
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Expanded(child: Text('Erro ao carregar: $e')),
              data: (items) {
                var filtered = items.where((c) {
                  final matchesSearch = _search.isEmpty ||
                      c.name.toLowerCase().contains(_search) ||
                      (c.description?.toLowerCase().contains(_search) ?? false);
                  final matchesCat = _selectedCategory == null || (c.category ?? '') == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  return const Expanded(child: Center(child: Text('Nenhum contador encontrado.')));
                }

                // Rebuild a cada segundo para contagem dinâmica
                return Expanded(
                  child: StreamBuilder<DateTime>(
                    stream: Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    initialData: DateTime.now(),
                    builder: (context, snap) {
                      final now = snap.data ?? DateTime.now();

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          int crossAxisCount = 1;
                          if (width >= 1400) {
                            crossAxisCount = 3;
                          } else if (width >= 900) {
                            crossAxisCount = 2;
                          }

                          Widget buildCard(int index) {
                            final c = filtered[index];
                            final rec = Recurrence.fromString(c.recurrence);
                            // Usa reconstrução ingênua local para garantir semântica de parede
                            final baseLocal = DateTime(
                              c.eventDate.year,
                              c.eventDate.month,
                              c.eventDate.day,
                              c.eventDate.hour,
                              c.eventDate.minute,
                              c.eventDate.second,
                              c.eventDate.millisecond,
                              c.eventDate.microsecond,
                            );
                            final effectiveDate = rec == Recurrence.none
                                ? baseLocal
                                : nextRecurringDate(baseLocal, rec, now);
                            final isFuture = effectiveDate.isAfter(now);
                            final comps = _calendarComponents(now, effectiveDate);
                            final days = comps.days;
                            final hours = comps.hours;
                            final mins = comps.minutes;
                            final secs = comps.seconds;
                            final tint = isFuture ? Colors.blue[50]! : Colors.red[50]!;

                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                              ),
                                              Wrap(spacing: 8, children: [
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
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(spacing: 8, runSpacing: 6, children: [
                                            if ((c.category ?? '').isNotEmpty)
                                              Chip(label: Text(c.category!), visualDensity: VisualDensity.compact),
                                            () {
                                              if (rec == Recurrence.none) return const SizedBox.shrink();
                                              return Chip(
                                                label: Text(_labelForRecurrence(rec)),
                                                visualDensity: VisualDensity.compact,
                                              );
                                            }(),
                                          ]),
                                          const SizedBox(height: 12),
                                          Wrap(spacing: 6, runSpacing: 6, children: [
                                            if (comps.years > 0) _CounterBox(value: comps.years, label: 'Anos', tint: tint),
                                            if (comps.months > 0) _CounterBox(value: comps.months, label: 'Meses', tint: tint),
                                            _CounterBox(value: days, label: 'Dias', tint: tint),
                                            _CounterBox(value: hours, label: 'Horas', tint: tint),
                                            _CounterBox(value: mins, label: 'Mins', tint: tint),
                                            _CounterBox(value: secs, label: 'Segs', tint: tint),
                                          ]),
                                          const SizedBox(height: 12),
                                          Text(
                                            () {
                                              final formatted = DateFormat('dd/MM/yyyy HH:mm').format(effectiveDate);
                                              return isFuture ? 'Evento em $formatted' : 'Desde $formatted';
                                            }(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (crossAxisCount == 1) {
                            // Em telas estreitas, use ListView para permitir altura variável dos cards
                            return ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) => buildCard(index),
                            );
                          }

                          // Para múltiplas colunas, mantenha GridView com uma razão mais alta
                          final aspectRatio = crossAxisCount == 2 ? 2.4 : 2.8;
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: aspectRatio,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => buildCard(index),
                          );
                        },
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

class _CounterBox extends StatelessWidget {
  final int value;
  final String label;
  final Color tint;
  const _CounterBox({required this.value, required this.label, required this.tint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}