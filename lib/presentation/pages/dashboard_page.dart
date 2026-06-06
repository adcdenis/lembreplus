import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/core/text_sanitizer.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lembreplus/presentation/widgets/animated_button.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String _labelForRecurrenceString(String? recurrence) {
    return RecurrenceDefinition.parse(recurrence).label;
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
      formattedTime +=
          '${comps.minutes} minuto${comps.minutes == 1 ? '' : 's'}, ';
    }
    if (comps.seconds > 0) {
      formattedTime +=
          '${comps.seconds} segundo${comps.seconds == 1 ? '' : 's'}, ';
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
🔄 **Repetição:** ${_labelForRecurrenceString(counter.recurrence)}
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
    final notifService = ref.read(notificationServiceProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: countersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erro ao carregar: $e')),
        data: (counters) {
          final now = DateTime.now();
          DateTime effectiveDate(DateTime base, String? recurrence) {
            final definition = RecurrenceDefinition.parse(recurrence);
            return definition.isNone
                ? base
                : nextRecurringDateFromString(base, recurrence, now);
          }

          // Métricas principais
          final total = counters.length;
          final recurring = counters
              .where(
                (c) => !RecurrenceDefinition.parse(c.recurrence).isNone,
              )
              .length;
          final past = counters
              .where(
                (c) =>
                    isPast(effectiveDate(c.eventDate, c.recurrence), now: now),
              )
              .length;
          final future = counters
              .where(
                (c) =>
                    !isPast(effectiveDate(c.eventDate, c.recurrence), now: now),
              )
              .length;

          // Semana atual (seg->dom) e próxima semana
          final startWeek = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: now.weekday - 1));
          final endWeek = startWeek.add(const Duration(days: 7));
          final startNextWeek = endWeek;
          final endNextWeek = startNextWeek.add(const Duration(days: 7));
          bool inRange(DateTime d, DateTime a, DateTime b) =>
              !d.isBefore(a) && d.isBefore(b);
          final weekCount = counters
              .where(
                (c) => inRange(
                  effectiveDate(c.eventDate, c.recurrence),
                  startWeek,
                  endWeek,
                ),
              )
              .length;
          final nextWeekCount = counters
              .where(
                (c) => inRange(
                  effectiveDate(c.eventDate, c.recurrence),
                  startNextWeek,
                  endNextWeek,
                ),
              )
              .length;

          // Mês atual
          final startMonth = DateTime(now.year, now.month, 1);
          final endMonth = DateTime(now.year, now.month + 1, 1);
          final monthCount = counters
              .where(
                (c) => inRange(
                  effectiveDate(c.eventDate, c.recurrence),
                  startMonth,
                  endMonth,
                ),
              )
              .length;

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
            for (var i = 0; i < labels.length; i++) labels[i]: palette[i],
          };

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com gradiente sutil
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dashboard',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          ),
                          Text(
                            'Visão completa dos seus contadores',
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cards principais (grid: garante 2 colunas no mobile)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    final cross = isNarrow ? 2 : 4;
                    final extent = isNarrow ? 110.0 : 110.0;
                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        mainAxisExtent: extent,
                      ),
                      children: [
                        _statCard(context, title: 'Total', value: total, color: cs.primaryContainer, icon: Icons.format_list_numbered_rounded, width: double.infinity),
                        _statCard(context, title: 'Passados', value: past, color: cs.secondaryContainer, icon: Icons.history_rounded, width: double.infinity),
                        _statCard(context, title: 'Futuros', value: future, color: cs.tertiaryContainer, icon: Icons.upcoming_rounded, width: double.infinity),
                        _statCard(context, title: 'Recorrentes', value: recurring, color: isDark ? Colors.green.shade900.withValues(alpha: 0.6) : Colors.green.shade100, icon: Icons.repeat_rounded, width: double.infinity),
                        _statCard(context, title: 'Esta Semana', value: weekCount, color: isDark ? Colors.amber.shade900.withValues(alpha: 0.6) : Colors.amber.shade100, icon: Icons.date_range_rounded, width: double.infinity),
                        _statCard(context, title: 'Este Mês', value: monthCount, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, icon: Icons.calendar_month_rounded, width: double.infinity),
                        _statCard(context, title: 'Próx. Semana', value: nextWeekCount, color: isDark ? Colors.orange.shade900.withValues(alpha: 0.6) : Colors.orange.shade100, icon: Icons.skip_next_rounded, width: double.infinity),
                        FutureBuilder<List<PendingNotificationRequest>>(
                          future: notifService.getPendingNotifications(),
                          builder: (context, snapshot) {
                            return _statCard(context, title: 'Notificações', value: snapshot.data?.length ?? 0, color: isDark ? Colors.blue.shade900.withValues(alpha: 0.6) : Colors.blue.shade100, icon: Icons.notifications_active_rounded, width: double.infinity);
                          },
                        ),
                      ].animate(interval: 40.ms).fadeIn(duration: 300.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOut),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Grade inferior: próximos eventos, barras de categoria, donut
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1100;
                    final leftPanel = _panelCard(
                      context,
                      title: 'Próximos Eventos',
                      icon: Icons.schedule_rounded,
                      accentColor: cs.primary,
                      child: StreamBuilder<DateTime>(
                        stream: Stream<DateTime>.periodic(
                          const Duration(seconds: 1),
                          (_) => DateTime.now(),
                        ),
                        initialData: DateTime.now(),
                        builder: (context, snap) {
                          final n = snap.data ?? DateTime.now();
                          final upcomingDyn =
                              counters
                                  .map((c) {
                                    final definition = RecurrenceDefinition.parse(
                                      c.recurrence,
                                    );
                                    final d = definition.isNone
                                        ? c.eventDate
                                        : nextRecurringDateFromString(
                                            c.eventDate,
                                            c.recurrence,
                                            n,
                                          );
                                    return (c, d);
                                  })
                                  .where((t) => !isPast(t.$2, now: n))
                                  .toList()
                                ..sort((a, b) => a.$2.compareTo(b.$2));
                          final nextFiveDyn = upcomingDyn.take(5).toList();
                          if (nextFiveDyn.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.event_available, size: 40, color: cs.onSurface.withValues(alpha: 0.2)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sem eventos futuros',
                                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (var i = 0; i < nextFiveDyn.length; i++) ...[
                                _upcomingTile(context, nextFiveDyn[i].$1, nextFiveDyn[i].$2, n),
                                if (i < nextFiveDyn.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 2,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: cs.primary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          );
                        },
                      ),
                    );

                    final middlePanel = _panelCard(
                      context,
                      title: 'Distribuição por Categoria',
                      icon: Icons.bar_chart_rounded,
                      accentColor: cs.tertiary,
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
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.category_outlined, size: 40, color: cs.onSurface.withValues(alpha: 0.2)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sem categorias',
                                      style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );

                    final rightPanel = _panelCard(
                      context,
                      title: 'Proporção por Categoria',
                      icon: Icons.donut_large_rounded,
                      accentColor: cs.secondary,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: _DonutChart(
                              data: byCategory,
                              total: total,
                              colorsByCategory: colorsByCategory,
                            ),
                          ),
                          if (categoryEntries.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              children: categoryEntries.map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: colorsByCategory[e.key],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${e.key} (${e.value})',
                                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: leftPanel),
                          const SizedBox(width: 12),
                          Expanded(child: middlePanel),
                          const SizedBox(width: 12),
                          Expanded(child: rightPanel),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        leftPanel,
                        const SizedBox(height: 12),
                        middlePanel,
                        const SizedBox(height: 12),
                        rightPanel,
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _pluralize(int v, String singular, String plural) =>
      v == 1 ? singular : plural;

  Widget _statCard(
    BuildContext context, {
    required String title,
    required int value,
    required Color color,
    required IconData icon,
    required double width,
  }) {
    final cs = Theme.of(context).colorScheme;
    // Map text color according to background for good contrast.
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
      final isLightBg =
          ThemeData.estimateBrightnessForColor(color) == Brightness.light;
      onColor = isLightBg ? Colors.black.withValues(alpha: 0.87) : Colors.white;
    }
    return AnimatedInteractiveItem(
      child: Card(
        elevation: 0,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outline.withValues(alpha: 0.08)),
        ),
        child: SizedBox(
          width: width,
          height: 96,
          child: Stack(
            children: [
              // Watermark icon
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  icon,
                  size: 56,
                  color: onColor.withValues(alpha: 0.06),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: onColor.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: onColor,
                        height: 1.0,
                      ),
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

  Widget _panelCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar on top
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.3)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: accentColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _upcomingTile(
    BuildContext context,
    Counter counter,
    DateTime date,
    DateTime now,
  ) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('dd/MM/yyyy');
    final cal = calendarDiff(now, date);
    return AnimatedInteractiveItem(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            // Timeline dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          counter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 18),
                        color: cs.onSurfaceVariant,
                        onPressed: () =>
                            _shareCounter(context, counter, date, true),
                        tooltip: 'Compartilhar',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.event_outlined, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        df.format(date),
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                      ),
                      if (counter.category != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            counter.category!,
                            style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
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
                          _dashCounterBox(
                            context: context,
                            value: cal.years,
                            label: _pluralize(cal.years, 'Ano', 'Anos'),
                            tint: cs.primaryContainer,
                          ),
                          const SizedBox(width: 4),
                        ],
                        if (cal.months > 0) ...[
                          _dashCounterBox(
                            context: context,
                            value: cal.months,
                            label: _pluralize(cal.months, 'Mês', 'Meses'),
                            tint: cs.primaryContainer,
                          ),
                          const SizedBox(width: 4),
                        ],
                        _dashCounterBox(
                          context: context,
                          value: cal.days,
                          label: _pluralize(cal.days, 'Dia', 'Dias'),
                          tint: cs.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                        _dashCounterBox(
                          context: context,
                          value: cal.hours,
                          label: _pluralize(cal.hours, 'Hora', 'Horas'),
                          tint: cs.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                        _dashCounterBox(
                          context: context,
                          value: cal.minutes,
                          label: _pluralize(cal.minutes, 'Minuto', 'Minutos'),
                          tint: cs.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                        _dashCounterBox(
                          context: context,
                          value: cal.seconds,
                          label: _pluralize(cal.seconds, 'Segundo', 'Segundos'),
                          tint: cs.primaryContainer,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Box de contador visualmente alinhado com a lista de contadores
  Widget _dashCounterBox({
    required BuildContext context,
    required int value,
    required String label,
    required Color tint,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint.withValues(alpha: isDark ? 0.4 : 0.85), tint.withValues(alpha: isDark ? 0.2 : 0.5)],
        ),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _categoryBar(
    BuildContext context, {
    required String label,
    required int value,
    required int max,
    required Color color,
  }) {
    final cs = Theme.of(context).colorScheme;
    final pct = max == 0 ? 0.0 : value / max;
    final barColor = color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 6),
                    Text('$value', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: cs.surfaceContainerHighest),
                        FractionallySizedBox(
                          widthFactor: pct,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [barColor, barColor.withValues(alpha: 0.7)],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
  const _DonutChart({
    required this.data,
    required this.total,
    required this.colorsByCategory,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _DonutPainter(
        data: data,
        total: total,
        colorsByCategory: colorsByCategory,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            Text(
              '$total',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
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
  _DonutPainter({
    required this.data,
    required this.total,
    required this.colorsByCategory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..color = Colors.grey.withValues(alpha: 0.1);
    canvas.drawArc(rect, 0, 2 * 3.1415926, false, bg);

    if (total <= 0 || data.isEmpty) return;

    double start = -3.1415926 / 2; // topo
    for (final e in data.entries) {
      final sweep = (e.value / total) * 2 * 3.1415926;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round
        // Usa mapeamento de cor único por categoria
        ..color = colorsByCategory[e.key] ?? Colors.grey;
      canvas.drawArc(rect, start, sweep - 0.02, false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.total != total;
  }
}
