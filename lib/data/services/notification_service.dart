import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Стрим для прослушивания кликов по уведомлениям
  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Инициализация базы часовых поясов
    tz.initializeTimeZones();

    // 2. Получение таймзоны через нативный канал
    String timeZoneName;
    try {
      const platform = MethodChannel('com.midas.aion/time_zone');
      timeZoneName = await platform.invokeMethod('getLocalTimeZone');
    } catch (e) {
      print("⚠️ Ошибка нативного канала: $e");
      timeZoneName = 'UTC'; // Фолбэк на случай сбоя
    }

    // Применяем таймзону
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("✅ Timezone set to: $timeZoneName");
    } catch (e) {
      print("⚠️ Неизвестная таймзона '$timeZoneName', ставим UTC");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 3. Настройки уведомлений
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Payload received: ${response.payload}");
        // Отправляем payload в стрим при клике
        if (response.payload != null) {
          selectNotificationStream.add(response.payload);
        }
      },
    );

    await _createNotificationChannel();

    _isInitialized = true;
    print("✅ NotificationService: Fully Initialized");
  }

  // Проверка холодного старта (запуск через пуш)
  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prayer_channel_system',
      'Adhan Notifications',
      description: 'Notifications for Prayer Times',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();

      // Запрос прав на точные будильники (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload, // Принимаем полезную нагрузку
  }) async {
    final tz.TZDateTime tzScheduledTime =
    tz.TZDateTime.from(scheduledTime, tz.local);

    // Если время уже прошло
    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel_system',
          'Adhan Notifications',
          channelDescription: 'Time for prayer',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      // УДАЛЕНО: matchDateTimeComponents: DateTimeComponents.time,
      // Уведомления должны быть строго одноразовыми, так как время намаза меняется каждый день!
    );

    print("📅 Scheduled: $title at $tzScheduledTime");
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}