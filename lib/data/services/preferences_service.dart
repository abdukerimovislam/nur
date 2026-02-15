import 'dart:convert'; // Добавлен импорт для работы с JSON
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

class PreferencesService {
  // Ключи для сохранения
  static const String _keyMethod = 'calculation_method';
  static const String _keyMadhab = 'madhab';
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySuhoorOffset = 'suhoor_alarm_offset';
  static const String _keyIftarOffset = 'iftar_alarm_offset';
  static const String _keyLanguage = 'language_code';
  static const String _keyTasbihCount = 'tasbih_count';

  // --- НОВЫЙ КЛЮЧ ДЛЯ ДНЕВНИКА ПОСТА ---
  static const String _fastingDaysKey = 'fasting_days_map';

  /// --- СОХРАНЕНИЕ НАСТРОЕК ---

  Future<void> saveCalculationMethod(CalculationMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    // Сохраняем имя метода как строку (enum.name)
    await prefs.setString(_keyMethod, method.name);
  }

  Future<void> saveSuhoorOffset(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySuhoorOffset, minutes);
  }

  Future<void> saveTasbihCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTasbihCount, count);
  }

  Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, code);
  }

  Future<void> saveIftarOffset(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyIftarOffset, minutes);
  }

  Future<void> saveMadhab(Madhab madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMadhab, madhab.name);
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  // --- НОВЫЙ БЛОК ДЛЯ ДНЕВНИКА ПОСТА ---

  // Сохраняем мапу в виде JSON: {"2026-02-18": "fasted", "2026-02-19": "missed"}
  Future<void> saveFastingDays(Map<String, String> daysMap) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(daysMap);
    await prefs.setString(_fastingDaysKey, jsonString);
  }

  /// --- ЧТЕНИЕ НАСТРОЕК ---

  Future<int> loadTasbihCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTasbihCount) ?? 0;
  }

  Future<int> loadSuhoorOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySuhoorOffset) ?? 30; // Дефолт: будить за полчаса
  }

  Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  Future<int> loadIftarOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyIftarOffset) ?? 0;
  }

  Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // По умолчанию уведомления включены (true)
    return prefs.getBool(_keyNotifications) ?? true;
  }

  Future<CalculationMethod?> loadCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final methodName = prefs.getString(_keyMethod);

    if (methodName == null) return null;

    try {
      return CalculationMethod.values.firstWhere((e) => e.name == methodName);
    } catch (e) {
      return null;
    }
  }

  Future<Madhab> loadMadhab() async {
    final prefs = await SharedPreferences.getInstance();
    final madhabName = prefs.getString(_keyMadhab);

    if (madhabName == null) return Madhab.hanafi;

    try {
      return Madhab.values.firstWhere((e) => e.name == madhabName);
    } catch (e) {
      return Madhab.hanafi;
    }
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  // --- НОВЫЙ БЛОК ДЛЯ ДНЕВНИКА ПОСТА ---
  Future<int> loadTasbihIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('tasbih_index') ?? 0;
  }

  Future<void> saveTasbihIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_index', index);
  }


  // Читаем мапу при запуске
  Future<Map<String, String>> loadFastingDays() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_fastingDaysKey);

    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      // Безопасно кастуем dynamic в String
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {}; // Защита от поврежденных данных (например, если кто-то обновил приложение)
    }
  }
}