import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lembreplus/data/database/app_database.dart';
import 'package:lembreplus/domain/recurrence.dart';
import 'package:lembreplus/domain/time_utils.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      // Define o fuso horário local padrão (pode precisar de ajuste dependendo da região do usuário,
      // mas 'local' geralmente funciona se o dispositivo estiver configurado corretamente)
      // tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Lógica ao clicar na notificação (navegação, etc)
        },
      );
    } catch (e) {
      debugPrint('NotificationService.init ignorado: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      } else if (Platform.isIOS) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      debugPrint('NotificationService.requestPermissions ignorado: $e');
    }
  }

  Future<void> scheduleNotifications({
    required int counterId,
    required String eventName,
    required DateTime eventDate,
    required List<int> offsetsMinutes,
  }) async {
    try {
      for (int i = 0; i < offsetsMinutes.length; i++) {
        final offset = offsetsMinutes[i];
        final scheduledDate = eventDate.subtract(Duration(minutes: offset));

        // Não agenda se já passou
        if (scheduledDate.isBefore(DateTime.now())) continue;

        // ID único: counterId * 100 + index (suporta até 100 alertas por contador)
        final notificationId = counterId * 100 + i;

        await _notificationsPlugin.zonedSchedule(
          notificationId,
          'Lembrete de Evento',
          'O evento "$eventName" será em ${eventDate.day.toString().padLeft(2, '0')}/${eventDate.month.toString().padLeft(2, '0')}/${eventDate.year} às ${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}',
          tz.TZDateTime.from(scheduledDate, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'lembreplus_channel',
              'Lembretes',
              channelDescription: 'Notificações de contadores agendados',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('NotificationService.scheduleNotifications ignorado: $e');
    }
  }

  Future<void> syncAllCounterNotifications(AppDatabase db) async {
    await init();
    await cancelAll();

    final now = DateTime.now();
    final counters = await db.getAllCounters();
    for (final counter in counters) {
      final alerts = await db.getAlertsForCounter(counter.id);
      List<int> offsetsMinutes = alerts.map((a) => a.offsetMinutes).toList();
      if (offsetsMinutes.isEmpty && counter.alertOffset != null) {
        offsetsMinutes = [counter.alertOffset!];
      }
      if (offsetsMinutes.isEmpty) continue;

      final effectiveEventDate = RecurrenceDefinition.parse(counter.recurrence).isNone
          ? counter.eventDate
          : nextRecurringDateFromString(counter.eventDate, counter.recurrence, now);

      await scheduleNotifications(
        counterId: counter.id,
        eventName: counter.name,
        eventDate: effectiveEventDate,
        offsetsMinutes: offsetsMinutes,
      );
    }
  }

  Future<void> cancelNotificationsForCounter(int counterId) async {
    try {
      // Cancela até 100 possíveis notificações para este contador
      for (int i = 0; i < 100; i++) {
        final notificationId = counterId * 100 + i;
        await _notificationsPlugin.cancel(notificationId);
      }
    } catch (e) {
      debugPrint('NotificationService.cancelNotificationsForCounter ignorado: $e');
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService.cancelAll ignorado: $e');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('NotificationService.getPendingNotifications ignorado: $e');
      return [];
    }
  }
}
