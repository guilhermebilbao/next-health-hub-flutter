import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (!kIsWeb) {
      _requestPermissions();
    }
  }

  void _requestPermissions() {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    androidImplementation?.requestNotificationsPermission();
    androidImplementation?.requestExactAlarmsPermission();
  }

  /// Exibe uma notificação mesmo em foreground
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'main_channel',
          'Notificações Gerais',
          channelDescription: 'Canal principal de notificações',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// TODO apos apresentacao retirar esse método de demonstracao
  Future<void> showInstantNotification() async {
    await showNotification(
      title: 'Parabéns para voce! 🎂',
      body:
          'A equipe Next Health Hub te deseja um feliz aniversário e muita saúde!',
    );
  }

  Future<void> scheduleBirthdayNotification(
    DateTime birthDate,
    String name,
  ) async {
    final now = DateTime.now();
    // Agendado para as 09:00 da manhã no dia do aniversário
    var scheduledDate = DateTime(
      now.year,
      birthDate.month,
      birthDate.day,
      9,
      0,
    );

    // Se o aniversário deste ano já passou, agendara para o próximo ano
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        now.year + 1,
        birthDate.month,
        birthDate.day,
        9,
        0,
      );
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      100,
      'Parabéns, $name! 🎂',
      'A equipe Next Health Hub te deseja um feliz aniversário e muita saúde!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'birthday_channel',
          'Aniversário',
          channelDescription: 'Notificações de felicitações de aniversário',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }
}
