import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

class NurWidgetService {
  NurWidgetService._();

  static const String appGroupId = 'group.com.nur.widgets';

  static const String iOSPrayerWidgetName = 'NurWidgets';
  static const String iOSAyahWidgetName = 'NurAyahWidget';
  static const String iOSDuaWidgetName = 'NurDuaWidget';
  static const String iOSStreakWidgetName = 'NurStreakWidget';
  static const String androidWidgetName = 'NurPrayerWidget';

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('NurWidgetService init failed: $e');
    }
  }

  static Future<void> updatePrayerWidget({
    required String nextPrayerName,
    required String nextPrayerTime,
    required DateTime nextPrayerDate,
    required String timeRemaining,
    required String city,
    required int streak,
    required int todayProgressPercent,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'nextPrayerName',
        nextPrayerName,
      );
      await HomeWidget.saveWidgetData<String>(
        'nextPrayerTime',
        nextPrayerTime,
      );
      await HomeWidget.saveWidgetData<double>(
        'nextPrayerTimestamp',
        nextPrayerDate.millisecondsSinceEpoch.toDouble(),
      );
      await HomeWidget.saveWidgetData<String>(
        'timeRemaining',
        timeRemaining,
      );
      await HomeWidget.saveWidgetData<String>(
        'city',
        city,
      );
      await HomeWidget.saveWidgetData<int>(
        'streak',
        streak,
      );
      await HomeWidget.saveWidgetData<int>(
        'todayProgressPercent',
        todayProgressPercent,
      );

      await _updateAllWidgets();
    } catch (e) {
      debugPrint('Prayer widget update failed: $e');
    }
  }

  static Future<void> updateDailyContentWidget({
    required String ayahText,
    required String ayahReference,
    required String duaText,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('ayahText', ayahText);
      await HomeWidget.saveWidgetData<String>('ayahReference', ayahReference);
      await HomeWidget.saveWidgetData<String>('duaText', duaText);

      await _updateAllWidgets();
    } catch (e) {
      debugPrint('Daily content widget update failed: $e');
    }
  }

  static Future<void> _updateAllWidgets() async {
    await HomeWidget.updateWidget(
      iOSName: iOSPrayerWidgetName,
      androidName: androidWidgetName,
    );
    await HomeWidget.updateWidget(iOSName: iOSAyahWidgetName);
    await HomeWidget.updateWidget(iOSName: iOSDuaWidgetName);
    await HomeWidget.updateWidget(iOSName: iOSStreakWidgetName);
  }
}
