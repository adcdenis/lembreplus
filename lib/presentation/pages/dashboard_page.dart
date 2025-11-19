import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/core/text_sanitizer.dart';
import 'package:lembreplus/data/models/counter.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

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

  void _shareCounter(
    BuildContext context,
    Counter counter,
    DateTime effectiveDate,
    bool isFuture,
  ) {
    final now = DateTime.now();
    final comps = calendarDiff(now, effectiveDate);
    final timeText = isFuture ? 'Faltam' : 'Passaram';

    String formattedTime = '';
    if (comps.years > 0) {
      formattedTime += '${comps.years} ano${comps.years == 1 ? '' : 's'}, ';
    }
    if (comps.months > 0) {
      formattedTime += '${comps.months} mês${comps.months == 1 ? '' : 'es'}, ';
    }
    if (comps.days > 0) {
      formattedTime += '${comps.days} dia${comps.days == 1 ? '' : 's'}, ';
    }
    if (comps.hours > 0) {
      formattedTime += '${comps.hours} hora${comps.hours == 1 ? '' : 's'}, ';
    }
    if (comps.minutes > 0) {
      formattedTime += '${comps.minutes} minuto${comps.minutes == 1 ? '' : 's'}, ';
    }
    if (comps.seconds > 0) {
      formattedTime += '${comps.seconds} segundo${comps.seconds == 1 ? '' : 's'}, ';
    }

    // Remove a vírgula final se houver tempo formatado
    if (formattedTime.endsWith(', ')) {
      formattedTime = formattedTime.substring(0, formattedTime.length - 2);
    }

    final shareText =
        '''
📊 **${counter.name}**

${counter.description ?? 'Sem descrição'}

📅 **Data do evento:** ${DateFormat('dd/MM/yyyy HH:mm').format(counter.eventDate)}
🔄 **Repetição:** ${_labelForRecurrence(Recurrence.fromString(counter.recurrence))}
${counter.category?.isNotEmpty == true ? '🏷️ **Categoria:** ${counter.category}\n' : ''}
⏰ **Tempo ${timeText.toLowerCase()}:** ${formattedTime.isNotEmpty ? formattedTime : 'menos de 1 segundo'}

📱 Compartilhado por Lembre+
''';

    final sanitizedText = sanitizeForShare(shareText);
    final sanitizedSubject = sanitizeForShare('Contador: ${counter.name}');
    Share.share(sanitizedText, subject: sanitizedSubject);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countersAsync = ref.watch(countersProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: countersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar: $e')),
        data: (counters) {
          final now = DateTime.now();
          DateTime effectiveDate(DateTime base, String? recurrence) {
            final r = Recurrence.fromString(recurrence);
            return nextRecurringDate(base, r, now);
          }

          // Métricas principais
          final total = counters.length;
          final recurring = counters.where((c) => Recurrence.fromString(c.recurrence) != Recurrence.none).length;
          final past = counters.where((c) => isPast(effectiveDate(c.eventDate, c.recurrence), now: now)).length;
          final future = counters.where((c) => !isPast(effectiveDate(c.eventDate, c.recurrence), now: now)).length;

          // Semana atual (seg->dom) e próxima semana
          final startWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          final endWeek = startWeek.add(const Duration(days: 7));
          final startNextWeek = endWeek;
          final endNextWeek = startNextWeek.add(const Duration(days: 7));
          bool inRange(DateTime d, DateTime a, DateTime b) => !d.isBefore(a) && d.isBefore(b);
          final weekCount = counters.where((c) => inRange(effectiveDate(c.eventDate, c.recurrence), startWeek, endWeek)).length;
          final nextWeekCount = counters.where((c) => inRange(effectiveDate(c.eventDate, c.recurrence), startNextWeek, endNextWeek)).length;

          // Mês atual
          final startMonth = DateTime(now.year, now.month, 1);
          final endMonth = DateTime(now.year, now.month + 1, 1);
          final monthCount = counters.where((c) => inRange(effectiveDate(c.eventDate, c.recurrence), startMonth, endMonth)).length;

          

          // Distribuição por categoria
          final Map<String, int> byCategory = {};
          for (final c in counters) {
            final k = (c.category ?? 'Sem categoria');
            byCategory[k] = (byCategory[k] ?? 0) + 1;
          }
          final categoryEntries = byCategory.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Paleta distinta por categoria (evita cores iguais)
          final labels = categoryEntries.map((e) => e.key).toList();
          final palette = _distinctPalette(context, labels.length);
          final Map<String, Color> colorsByCategory = {
            for (var i = 0; i < labels.length; i++) labels[i]: palette[i]
          };

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Visão completa dos seus contadores e eventos', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 16),

                // Cards principais (grid: garante 2 colunas no mobile)
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  final cross = isNarrow ? 2 : 4;
                  final extent = isNarrow ? 110.0 : 110.0;
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cross,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: extent,
                    ),
                    children: [
  _statCard(context, title: 'Total', value: total, color: cs.primaryContainer, emoji: '📋', width: double.infinity),
  _statCard(context, title: 'Passados', value: past, color: cs.secondaryContainer, emoji: '🕰️', width: double.infinity),
  _statCard(context, title: 'Futuros', value: future, color: cs.tertiaryContainer, emoji: '🗓️', width: double.infinity),
  _statCard(context, title: 'Recorrentes', value: recurring, color: Colors.green.shade100, emoji: '🔁', width: double.infinity),
  _statCard(context, title: 'Esta Semana', value: weekCount, color: Colors.amber.shade100, emoji: '📅', width: double.infinity),
  _statCard(context, title: 'Este Mês', value: monthCount, color: Colors.grey.shade200, emoji: '🗓️', width: double.infinity),
  _statCard(context, title: 'Próx. Semana', value: nextWeekCount, color: Colors.orange.shade100, emoji: '⏭️', width: double.infinity),
  _statCard(context, title: 'Vencidos', value: past, color: cs.errorContainer, emoji: '⚠️', width: double.infinity),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                // Grade inferior: próximos eventos, barras de categoria, donut
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1100;
                  final leftPanel = _panelCard(
                    context,
                    title: 'Próximos Eventos',
                    emoji: '⏳',
                    child: StreamBuilder<DateTime>(
                      stream: Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                      initialData: DateTime.now(),
                      builder: (context, snap) {
                        final n = snap.data ?? DateTime.now();
                        final upcomingDyn = counters
                            .map((c) {
                              final r = Recurrence.fromString(c.recurrence);
                              final d = nextRecurringDate(c.eventDate, r, n);
                              return (c, d);
                            })
                            .where((t) => !isPast(t.$2, now: n))
                            .toList()
                          ..sort((a, b) => a.$2.compareTo(b.$2));
                        final nextFiveDyn = upcomingDyn.take(5).toList();
                        if (nextFiveDyn.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Sem eventos futuros', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                          );
                        }
                        return Column(
                          children: [
                            for (final t in nextFiveDyn)
                              _upcomingTile(context, t.$1, t.$2, n),
                          ],
                        );
                      },
                    ),
                  );

                  final middlePanel = _panelCard(
                    context,
                    title: 'Distribuição por Categoria',
                    emoji: '📊',
                    child: Column(
                      children: [
                        for (final e in categoryEntries)
                          _categoryBar(
                            context,
                            label: e.key,
                            value: e.value,
                            max: total,
                            color: colorsByCategory[e.key]!,
                          ),
                        if (categoryEntries.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text('Sem categorias', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                          ),
                      ],
                    ),
                  );

                  final rightPanel = _panelCard(
                    context,
                    title: 'Proporção por Categoria',
                    emoji: '🥧',
                    child: SizedBox(
                      height: 220,
                      child: _DonutChart(
                        data: byCategory,
                        total: total,
                        colorsByCategory: colorsByCategory,
                      ),
                    ),
                  );

                  if (isWide) {
                    return Row(children: [
                      Expanded(child: leftPanel),
                      const SizedBox(width: 12),
                      Expanded(child: middlePanel),
                      const SizedBox(width: 12),
                      Expanded(child: rightPanel),
                    ]);
                  }
                  return Column(children: [
                    leftPanel,
                    const SizedBox(height: 12),
                    middlePanel,
                    const SizedBox(height: 12),
                    rightPanel,
                  ]);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  String _pluralize(int v, String singular, String plural) => v == 1 ? singular : plural;

  Widget _statCard(BuildContext context, {required String title, required int value, required Color color, required String emoji, required double width}) {
    final cs = Theme.of(context).colorScheme;
    // Choose an appropriate text color based on the container color for better contrast
    // Map text color according to background for good contrast.
    // Use theme on*Container for scheme containers, otherwise compute fallback based on brightness.
    final Color onColor;
    if (color == cs.primaryContainer) {
      onColor = cs.onPrimaryContainer;
    } else if (color == cs.secondaryContainer) {
      onColor = cs.onSecondaryContainer;
    } else if (color == cs.tertiaryContainer) {
      onColor = cs.onTertiaryContainer;
    } else if (color == cs.errorContainer) {
      onColor = cs.onErrorContainer;
    } else {
      final isLightBg = ThemeData.estimateBrightnessForColor(color) == Brightness.light;
      onColor = isLightBg ? Colors.black.withValues(alpha: 0.87) : Colors.white;
    }
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: cs.outline.withValues(alpha: 0.12))),
      child: SizedBox(
        width: width,
        height: 90,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 2),
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600, color: onColor)),
                    const SizedBox(height: 4),
                    Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelCard(BuildContext context, {required String title, required String emoji, required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: cs.outline.withValues(alpha: 0.12))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _upcomingTile(BuildContext context, Counter counter, DateTime date, DateTime now) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd/MM/yyyy');
    final cal = calendarDiff(now, date);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      counter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    color: cs.onSurfaceVariant,
                    onPressed: () => _shareCounter(context, counter, date, true),
                    tooltip: 'Compartilhar',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(df.format(date), style: TextStyle(color: cs.onSurfaceVariant)),
                  if (counter.category != null)
                    Chip(
                      avatar: const Text('🏷️'),
                      label: Text(counter.category!),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cal.years > 0) ...[
                      _DashCounterBox(context: context, value: cal.years, label: _pluralize(cal.years, 'Ano', 'Anos'), tint: cs.primaryContainer),
                      const SizedBox(width: 4),
                    ],
                    if (cal.months > 0) ...[
                      _DashCounterBox(context: context, value: cal.months, label: _pluralize(cal.months, 'Mês', 'Meses'), tint: cs.primaryContainer),
                      const SizedBox(width: 4),
                    ],
                    _DashCounterBox(context: context, value: cal.days, label: _pluralize(cal.days, 'Dia', 'Dias'), tint: cs.primaryContainer),
                    const SizedBox(width: 4),
                    _DashCounterBox(context: context, value: cal.hours, label: _pluralize(cal.hours, 'Hora', 'Horas'), tint: cs.primaryContainer),
                    const SizedBox(width: 4),
                    _DashCounterBox(context: context, value: cal.minutes, label: _pluralize(cal.minutes, 'Minuto', 'Minutos'), tint: cs.primaryContainer),
                    const SizedBox(width: 4),
                    _DashCounterBox(context: context, value: cal.seconds, label: _pluralize(cal.seconds, 'Segundo', 'Segundos'), tint: cs.primaryContainer),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  // Box de contador visualmente alinhado com a lista de contadores
  Widget _DashCounterBox({required BuildContext context, required int value, required String label, required Color tint}) {
    final cs = Theme.of(context).colorScheme;
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
          Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _categoryBar(BuildContext context, {required String label, required int value, required int max, required Color color}) {
    final cs = Theme.of(context).colorScheme;
    final pct = max == 0 ? 0.0 : value / max;
    final barColor = color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.circle, size: 10, color: barColor),
                const SizedBox(width: 6),
                Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 6),
                Text('$value'),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 8,
                  child: Stack(children: [
                    Container(color: cs.surfaceContainerHighest),
                    FractionallySizedBox(widthFactor: pct, child: Container(color: barColor)),
                  ]),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Gera uma paleta distinta de cores para a quantidade solicitada,
  // distribuindo as cores pelo círculo de matiz (HSL) para evitar colisões.
  List<Color> _distinctPalette(BuildContext context, int count) {
    final brightness = Theme.of(context).brightness;
    final double s = brightness == Brightness.dark ? 0.65 : 0.60;
    final double l = brightness == Brightness.dark ? 0.55 : 0.50;
    if (count <= 0) return const [];
    return List<Color>.generate(count, (i) {
      final hue = (360.0 * i / count) % 360.0;
      return HSLColor.fromAHSL(1.0, hue, s, l).toColor();
    });
  }
}

class _DonutChart extends StatelessWidget {
  final Map<String, int> data;
  final int total;
  final Map<String, Color> colorsByCategory;
  const _DonutChart({required this.data, required this.total, required this.colorsByCategory});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DonutPainter(data: data, total: total, colorsByCategory: colorsByCategory),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Total'),
            Text('$total', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final Map<String, int> data;
  final int total;
  final Map<String, Color> colorsByCategory;
  _DonutPainter({required this.data, required this.total, required this.colorsByCategory});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..color = Colors.grey.withValues(alpha: 0.15);
    canvas.drawArc(rect, 0, 2 * 3.1415926, false, bg);

    if (total <= 0 || data.isEmpty) return;

    double start = -3.1415926 / 2; // topo
    for (final e in data.entries) {
      final sweep = (e.value / total) * 2 * 3.1415926;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 26
        ..strokeCap = StrokeCap.butt
        // Usa mapeamento de cor único por categoria
        ..color = colorsByCategory[e.key] ?? Colors.grey;
      canvas.drawArc(rect, start, sweep, false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}