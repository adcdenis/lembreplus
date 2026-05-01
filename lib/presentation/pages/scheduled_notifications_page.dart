import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lembreplus/state/providers.dart';
import 'package:lembreplus/data/models/counter.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lembreplus/presentation/widgets/animated_button.dart';

class ScheduledNotificationsPage extends ConsumerStatefulWidget {
  const ScheduledNotificationsPage({super.key});

  @override
  ConsumerState<ScheduledNotificationsPage> createState() => _ScheduledNotificationsPageState();
}

class _ScheduledNotificationsPageState extends ConsumerState<ScheduledNotificationsPage> {
  String _formatAlertOffset(int minutes) {
    if (minutes < 60) return '$minutes min antes';
    if (minutes < 1440) return '${minutes ~/ 60} h antes';
    if (minutes < 10080) return '${minutes ~/ 1440} d antes';
    return '${minutes ~/ 10080} sem antes';
  }

  String _pluralize(int value, String singular, String plural) =>
      value == 1 ? singular : plural;

  TimeDiffComponents _calendarComponents(DateTime a, DateTime b) {
    return calendarDiff(a, b);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countersAsync = ref.watch(countersProvider);
    final notifService = ref.read(notificationServiceProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/counters'),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Notificações Agendadas',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            countersAsync.when(
              loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Expanded(child: Text('Erro ao carregar: $e')),
              data: (counters) => FutureBuilder<List<PendingNotificationRequest>>(
                future: notifService.getPendingNotifications(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Expanded(child: Center(child: CircularProgressIndicator()));
                  }

                  final pendingNotifications = snapshot.data!;
                  final now = DateTime.now();

                  final notificationItems = <_NotificationItem>[];

                  for (final pending in pendingNotifications) {
                    final counterId = pending.id ~/ 100;
                    final alertIndex = pending.id % 100;

                    final counter = counters.where((c) => c.id == counterId).firstOrNull;
                    if (counter == null) continue;

                    final definition = RecurrenceDefinition.parse(counter.recurrence);
                    final baseLocal = DateTime(
                      counter.eventDate.year,
                      counter.eventDate.month,
                      counter.eventDate.day,
                      counter.eventDate.hour,
                      counter.eventDate.minute,
                    );
                    final effectiveDate = definition.isNone
                        ? baseLocal
                        : nextRecurringDateFromString(baseLocal, counter.recurrence, now);

                    String offsetLabel;
                    DateTime scheduledDate;
                    if (alertIndex < counter.alertOffsets.length) {
                      final offsetMinutes = counter.alertOffsets[alertIndex];
                      scheduledDate = effectiveDate.subtract(Duration(minutes: offsetMinutes));
                      offsetLabel = _formatAlertOffset(offsetMinutes);
                    } else {
                      scheduledDate = effectiveDate;
                      offsetLabel = 'no evento';
                    }

                    notificationItems.add(_NotificationItem(
                      pending: pending,
                      counter: counter,
                      scheduledDate: scheduledDate,
                      effectiveDate: effectiveDate,
                      offsetLabel: offsetLabel,
                    ));
                  }

                  notificationItems.sort((a, b) {
                    return a.scheduledDate.compareTo(b.scheduledDate);
                  });

                  if (notificationItems.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma notificação agendada',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: StreamBuilder<DateTime>(
                      stream: Stream<DateTime>.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                      initialData: now,
                      builder: (context, snap) {
                        final currentNow = snap.data ?? now;

                        return ListView.separated(
                          itemCount: notificationItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = notificationItems[index];
                            final comps = _calendarComponents(currentNow, item.scheduledDate);
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            final isFuture = item.scheduledDate.isAfter(currentNow);
                            final pastColor = Colors.amber.shade100;
                            final tint = isFuture
                                ? scheme.primaryContainer
                                : pastColor;

                            return AnimatedInteractiveItem(
                              child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  context.push('/counter/${item.counter.id}/edit');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: scheme.outlineVariant,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isFuture
                                          ? [
                                              scheme.primaryContainer.withValues(alpha: isDark ? 0.3 : 0.6),
                                              scheme.primaryContainer.withValues(alpha: isDark ? 0.1 : 0.3),
                                            ]
                                          : [
                                              pastColor.withValues(alpha: isDark ? 0.3 : 0.6),
                                              pastColor.withValues(alpha: isDark ? 0.1 : 0.3),
                                            ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isFuture
                                              ? scheme.primary.withValues(alpha: 0.1)
                                              : pastColor.withValues(alpha: isDark ? 0.1 : 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          isFuture ? Icons.notifications_active : Icons.notifications_paused,
                                          color: isFuture ? scheme.primary : (isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.counter.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_alarm, size: 14, color: scheme.onSurfaceVariant),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Lembrete: ${item.offsetLabel}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: scheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.event, size: 14, color: scheme.onSurfaceVariant),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Evento: ${DateFormat('dd/MM/yyyy HH:mm').format(item.effectiveDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: scheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.notifications_none, size: 14, color: scheme.onSurfaceVariant),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Disparo: ${DateFormat('dd/MM/yyyy HH:mm').format(item.scheduledDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: isFuture ? scheme.primary : (isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                                                  ),
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
                                                  if (comps.years > 0) ...[
                                                    _TimeBox(
                                                      value: comps.years,
                                                      label: _pluralize(comps.years, 'Ano', 'Anos'),
                                                      tint: tint,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  if (comps.months > 0) ...[
                                                    _TimeBox(
                                                      value: comps.months,
                                                      label: _pluralize(comps.months, 'Mes', 'Meses'),
                                                      tint: tint,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  if (comps.days > 0) ...[
                                                    _TimeBox(
                                                      value: comps.days,
                                                      label: _pluralize(comps.days, 'Dia', 'Dias'),
                                                      tint: tint,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  if (comps.hours > 0) ...[
                                                    _TimeBox(
                                                      value: comps.hours,
                                                      label: _pluralize(comps.hours, 'Hora', 'Horas'),
                                                      tint: tint,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  if (comps.minutes > 0) ...[
                                                    _TimeBox(
                                                      value: comps.minutes,
                                                      label: _pluralize(comps.minutes, 'Minuto', 'Minutos'),
                                                      tint: tint,
                                                    ),
                                                    const SizedBox(width: 4),
                                                  ],
                                                  _TimeBox(
                                                    value: comps.seconds,
                                                    label: _pluralize(comps.seconds, 'Segundo', 'Segundos'),
                                                    tint: tint,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )).animate().fadeIn(duration: 400.ms, delay: (15 * index).ms).slideY(begin: 0.1, end: 0);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  final PendingNotificationRequest pending;
  final Counter counter;
  final DateTime scheduledDate;
  final DateTime effectiveDate;
  final String offsetLabel;

  _NotificationItem({
    required this.pending,
    required this.counter,
    required this.scheduledDate,
    required this.effectiveDate,
    required this.offsetLabel,
  });
}

class _TimeBox extends StatelessWidget {
  final int value;
  final String label;
  final Color tint;
  const _TimeBox({
    required this.value,
    required this.label,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: isDark ? 0.4 : 0.85), 
            tint.withValues(alpha: isDark ? 0.2 : 0.5)
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: tint.withValues(alpha: 0.28),
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
              color: scheme.onSurface,
            ),
          ),
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
