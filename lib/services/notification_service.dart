import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    // Define o fuso horário local padrão (pode precisar de ajuste dependendo da região do usuário,
    // mas 'local' geralmente funciona se o dispositivo estiver configurado corretamente)
    // tz.setLocalLocation(tz.getLocation('America/Sao_Paulo')); 

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração iOS (permissões solicitadas na hora do uso ou init)
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Lógica ao clicar na notificação (navegação, etc)
      },
    );
  }

  Future<void> requestPermissions() async {
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
  }

  Future<void> scheduleNotifications({
    required int counterId,
    required String eventName,
    required DateTime eventDate,
    required List<int> offsetsMinutes,
  }) async {
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
  }

  Future<void> cancelNotificationsForCounter(int counterId) async {
    // Cancela até 100 possíveis notificações para este contador
    for (int i = 0; i < 100; i++) {
      final notificationId = counterId * 100 + i;
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
