import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _prefsKeyFilterSearch = 'counter_list_filter_search';
  static const _prefsKeyFilterCategory = 'counter_list_filter_category';
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
  String _pluralize(int value, String singular, String plural) => value == 1 ? singular : plural;
  
  TimeDiffComponents _calendarComponents(DateTime a, DateTime b) {
    // Usa diferença de calendário normalizada em horário local
    return calendarDiff(a, b);
  }
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSearch = prefs.getString(_prefsKeyFilterSearch) ?? '';
      final savedCategory = prefs.getString(_prefsKeyFilterCategory);
      if (mounted) {
        setState(() {
          _search = savedSearch;
          _selectedCategory = (savedCategory?.isNotEmpty ?? false) ? savedCategory : null;
        });
        _searchCtrl.text = savedSearch;
      }
    } catch (_) {
      // Ignora erros de persistência
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countersAsync = ref.watch(countersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final repo = ref.watch(counterRepositoryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/counter/new'),
        child: const Text('➕', style: TextStyle(fontSize: 24)),
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
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 20),
                      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      hintText: 'Buscar por descrição ou nome...',
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                    ),
                    onChanged: (v) async {
                      final nv = v.trim();
                      setState(() => _search = nv);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(_prefsKeyFilterSearch, nv);
                      } catch (_) {
                        // Ignora erros de persistência
                      }
                    },
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

                  // Inclui a categoria previamente salva mesmo se não houver contadores atuais com ela
                  final present = <String>{...presentCats};
                  if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
                    present.add(_selectedCategory!);
                  }
                  final dropdownItems = <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(value: null, child: Text('Todas as categorias')),
                    ...present.map((norm) => DropdownMenuItem<String?>(
                          value: norm,
                          child: Text(nameByNormalized[norm] ?? norm),
                        )),
                  ];

                  return SizedBox(
                    width: 240,
                    height: 48,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: dropdownItems,
                          onChanged: (v) async {
                            setState(() => _selectedCategory = v);
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              if (v == null || (v.isEmpty)) {
                                await prefs.remove(_prefsKeyFilterCategory);
                              } else {
                                await prefs.setString(_prefsKeyFilterCategory, v);
                              }
                            } catch (_) {
                              // Ignora erros de persistência
                            }
                          },
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
                  final q = _search.toLowerCase();
                  final matchesSearch = _search.isEmpty ||
                      c.name.toLowerCase().contains(q) ||
                      (c.description?.toLowerCase().contains(q) ?? false);
                  final matchesCat = _selectedCategory == null || (c.category ?? '') == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                // Ordena alfabeticamente por nome (case-insensitive)
                filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

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
                            final tint = isFuture ? scheme.primaryContainer : scheme.errorContainer;

                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => context.go('/counter/${c.id}/edit'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isFuture
                                          ? [scheme.primaryContainer.withValues(alpha: 0.6), scheme.primaryContainer.withValues(alpha: 0.3)]
                                          : [scheme.errorContainer.withValues(alpha: 0.6), scheme.errorContainer.withValues(alpha: 0.3)],
                                    ),
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
                                              Text(
                                                isFuture ? '🗓️' : '🕰️',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: isFuture ? scheme.primary : scheme.error,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                              ),
                                              Wrap(spacing: 8, children: [
                                                IconButton.filledTonal(
                                                  tooltip: 'Histórico',
                                                  icon: const Text('📜', style: TextStyle(fontSize: 20)),
                                                  onPressed: () => context.go('/counter/${c.id}/history'),
                                                ),
                                                IconButton.filledTonal(
                                                  tooltip: 'Excluir',
                                                  icon: const Text('🗑️', style: TextStyle(fontSize: 20)),
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
                                              Chip(
                                                avatar: Text('🏷️', style: TextStyle(fontSize: 14, color: scheme.onSecondaryContainer)),
                                                label: Text(c.category!),
                                                visualDensity: VisualDensity.compact,
                                                backgroundColor: scheme.secondaryContainer,
                                                labelStyle: TextStyle(color: scheme.onSecondaryContainer),
                                              ),
                                            () {
                                              if (rec == Recurrence.none) return const SizedBox.shrink();
                                              return Chip(
                                                avatar: Text('🔁', style: TextStyle(fontSize: 16, color: scheme.onTertiaryContainer)),
                                                label: Text(_labelForRecurrence(rec)),
                                                visualDensity: VisualDensity.compact,
                                                backgroundColor: scheme.tertiaryContainer,
                                                labelStyle: TextStyle(color: scheme.onTertiaryContainer),
                                              );
                                            }(),
                                          ]),
                                          const SizedBox(height: 12),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (comps.years > 0) ...[
                                                  _CounterBox(
                                                    value: comps.years,
                                                    label: _pluralize(comps.years, 'Ano', 'Anos'),
                                                    tint: tint,
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                                if (comps.months > 0) ...[
                                                  _CounterBox(
                                                    value: comps.months,
                                                    label: _pluralize(comps.months, 'Mês', 'Meses'),
                                                    tint: tint,
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                                _CounterBox(value: days, label: _pluralize(days, 'Dia', 'Dias'), tint: tint),
                                                const SizedBox(width: 4),
                                                _CounterBox(value: hours, label: _pluralize(hours, 'Hora', 'Horas'), tint: tint),
                                                const SizedBox(width: 4),
                                                _CounterBox(value: mins, label: _pluralize(mins, 'Minuto', 'Minutos'), tint: tint),
                                                const SizedBox(width: 4),
                                                _CounterBox(value: secs, label: _pluralize(secs, 'Segundo', 'Segundos'), tint: tint),
                                              ],
                                            ),
                                          ),
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

                          // Para múltiplas colunas, aumente a altura dos cards para evitar overflow
                          final aspectRatio = crossAxisCount == 2 ? 1.8 : 2.1;
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _CounterBox extends StatelessWidget {
  final int value;
  final String label;
  final Color tint;
  const _CounterBox({required this.value, required this.label, required this.tint});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: 0.85), tint.withValues(alpha: 0.5)],
        ),
        boxShadow: [
          BoxShadow(color: tint.withValues(alpha: 0.28), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}