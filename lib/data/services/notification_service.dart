import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static const MethodChannel _timeZoneChannel =
  MethodChannel('com.midas.aion/time_zone');
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    final timeZoneName = await _resolveTimeZoneName();

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("✅ Timezone set to: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ Unknown timezone '$timeZoneName', falling back to UTC");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Payload received: ${response.payload}");
        if (response.payload != null) {
          selectNotificationStream.add(response.payload);
        }
      },
    );

    await _createNotificationChannel();

    _isInitialized = true;
    debugPrint("✅ NotificationService: Fully Initialized");
  }

  Future<String> _resolveTimeZoneName() async {
    try {
      final String? zone =
      await _timeZoneChannel.invokeMethod<String>('getLocalTimeZone');
      if (zone != null && zone.isNotEmpty) {
        return zone;
      }
    } catch (e) {
      debugPrint("⚠️ Timezone channel error: $e");
    }
    return 'UTC';
  }

  Future<NotificationAppLaunchDetails?> getLaunchDetails() async {
    return await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
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
      final androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();

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
    String? payload,
  }) async {
    final tz.TZDateTime tzScheduledTime =
    tz.TZDateTime.from(scheduledTime, tz.local);

    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    // ИСПРАВЛЕНИЕ: Защита от FATAL EXCEPTION на Android 14+ при отказе в доступе
    bool hasExactPermission = true;
    if (Platform.isAndroid) {
      hasExactPermission = await Permission.scheduleExactAlarm.isGranted;
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
      // Используем неточный будильник как fallback, если юзер не дал прав в Android 14
      androidScheduleMode: hasExactPermission
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("📅 Scheduled: $title at $tzScheduledTime");
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}