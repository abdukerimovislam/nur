import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  // Ключи для базы данных
  static const String _keyTasbihCount = 'tasbih_count';
  static const String _keyTasbihIndex = 'tasbih_index';
  static const String _keyFastingData = 'fasting_data';
  static const String _keyCity = 'user_city';
  static const String _keyLanguage = 'user_language';

  // Ключи для настроек молитв (PrayerProvider)
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySuhoorOffset = 'suhoor_offset';
  static const String _keyIftarOffset = 'iftar_offset';
  static const String _keyTahajjudOffset = 'tahajjud_offset';
  static const String _keyMadhab = 'user_madhab';
  static const String _keyCalcMethod = 'user_calc_method';

  // Ключи для ручной локации
  static const String _keyIsManualLocation = 'is_manual_location';
  static const String _keyManualLat = 'manual_lat';
  static const String _keyManualLng = 'manual_lng';
  static const String _keyCountryCode = 'country_code';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- МЕТОДЫ ДЛЯ ТАСБИХА ---
  int getTasbihCount() => _prefs.getInt(_keyTasbihCount) ?? 0;
  Future<void> saveTasbihCount(int count) async =>
      await _prefs.setInt(_keyTasbihCount, count);

  int getTasbihIndex() => _prefs.getInt(_keyTasbihIndex) ?? 0;
  Future<void> saveTasbihIndex(int index) async =>
      await _prefs.setInt(_keyTasbihIndex, index);

  // --- МЕТОДЫ ДЛЯ ДНЕВНИКА ПОСТА ---
  Map<String, String> getFastingData() {
    final String? jsonString = _prefs.getString(_keyFastingData);
    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveFastingData(Map<String, String> data) async {
    final String jsonString = jsonEncode(data);
    await _prefs.setString(_keyFastingData, jsonString);
  }

  // --- МЕТОДЫ ДЛЯ ЛОКАЦИИ (Город, Страна, Ручной режим) ---
  String? getCity() => _prefs.getString(_keyCity);
  Future<void> saveCity(String city) async =>
      await _prefs.setString(_keyCity, city);

  String? getCountryCode() => _prefs.getString(_keyCountryCode);
  Future<void> saveCountryCode(String code) async =>
      await _prefs.setString(_keyCountryCode, code);

  bool getIsManualLocation() => _prefs.getBool(_keyIsManualLocation) ?? false;
  Future<void> saveIsManualLocation(bool value) async =>
      await _prefs.setBool(_keyIsManualLocation, value);

  double? getManualLat() => _prefs.getDouble(_keyManualLat);
  double? getManualLng() => _prefs.getDouble(_keyManualLng);

  Future<void> saveManualLocation(
      double lat, double lng, String city, String countryCode) async {
    await _prefs.setDouble(_keyManualLat, lat);
    await _prefs.setDouble(_keyManualLng, lng);
    await saveCity(city);
    await saveCountryCode(countryCode);
  }

  // --- МЕТОДЫ ДЛЯ НАСТРОЕК (Язык и Будильники) ---
  String? getLanguage() => _prefs.getString(_keyLanguage);
  Future<void> saveLanguage(String langCode) async =>
      await _prefs.setString(_keyLanguage, langCode);

  bool getNotificationsEnabled() => _prefs.getBool(_keyNotifications) ?? true;
  Future<void> saveNotificationsEnabled(bool value) async =>
      await _prefs.setBool(_keyNotifications, value);

  int getSuhoorOffset() => _prefs.getInt(_keySuhoorOffset) ?? 30;
  Future<void> saveSuhoorOffset(int minutes) async =>
      await _prefs.setInt(_keySuhoorOffset, minutes);

  int getIftarOffset() => _prefs.getInt(_keyIftarOffset) ?? 0;
  Future<void> saveIftarOffset(int minutes) async =>
      await _prefs.setInt(_keyIftarOffset, minutes);

  int getTahajjudOffset() => _prefs.getInt(_keyTahajjudOffset) ?? 0;
  Future<void> saveTahajjudOffset(int minutes) async =>
      await _prefs.setInt(_keyTahajjudOffset, minutes);

  int? getMadhabIndex() => _prefs.getInt(_keyMadhab);
  Future<void> saveMadhabIndex(int index) async =>
      await _prefs.setInt(_keyMadhab, index);

  int? getCalculationMethodIndex() => _prefs.getInt(_keyCalcMethod);
  Future<void> saveCalculationMethodIndex(int index) async =>
      await _prefs.setInt(_keyCalcMethod, index);

  // --- НОВОЕ: МЕТОДЫ ДЛЯ РУЧНОЙ КОРРЕКТИРОВКИ ВРЕМЕНИ НАМАЗОВ (IHTIYAT) ---

  /// Получает сохраненное смещение в минутах для конкретного намаза (fajr, sunrise, dhuhr, asr, maghrib, isha)
  int getAdjustment(String prayerName) {
    return _prefs.getInt('adj_$prayerName') ?? 0;
  }

  /// Сохраняет смещение в минутах (может быть как положительным, так и отрицательным)
  Future<void> saveAdjustment(String prayerName, int minutes) async {
    await _prefs.setInt('adj_$prayerName', minutes);
  }
}
