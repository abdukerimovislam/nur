import 'dart:async';
import 'dart:io';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import '../data/services/location_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/notification_service.dart';
import '../core/localization/notification_dictionary.dart';

enum RamadanEvent { suhoor, iftar }

class PrayerProvider extends ChangeNotifier with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  PrayerTimes? _prayerTimes;
  Coordinates? _coordinates;

  RamadanEvent _currentEvent = RamadanEvent.suhoor;
  DateTime? _targetTime;
  DateTime? _startTime;
  Duration _timeRemaining = Duration.zero;

  String _city = "";
  String _country = "";
  String _countryCode = "";

  bool _isLoading = true;
  String? _error;
  StorageService getStorageService() => _storageService;

  CalculationMethod _method = CalculationMethod.muslim_world_league;
  Madhab _madhab = Madhab.hanafi;

  Locale _locale = const Locale('en');
  bool _notificationsEnabled = true;

  int _suhoorAlarmOffset = 30;
  int _iftarAlarmOffset = 0;

  int _tahajjudAlarmOffset = 0;
  DateTime? _tahajjudTime;

  Timer? _timer;
  int _currentDay = DateTime.now().day;

  bool _isScheduling = false;
  bool _needsReschedule = false;
  bool _isManualLocation = false;

  PrayerTimes? get prayerTimes => _prayerTimes;
  RamadanEvent get currentEvent => _currentEvent;
  DateTime? get targetTime => _targetTime;
  DateTime? get startTime => _startTime;
  Duration get timeRemaining => _timeRemaining;
  String get city => _city;
  String get country => _country;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CalculationMethod get method => _method;
  Madhab get madhab => _madhab;
  bool get notificationsEnabled => _notificationsEnabled;
  int get suhoorAlarmOffset => _suhoorAlarmOffset;
  int get iftarAlarmOffset => _iftarAlarmOffset;
  Locale get locale => _locale;
  bool get isManualLocation => _isManualLocation;
  int get tahajjudAlarmOffset => _tahajjudAlarmOffset;
  DateTime? get tahajjudTime => _tahajjudTime;

  Duration get timeElapsed {
    if (_startTime == null) return Duration.zero;
    final now = DateTime.now();
    if (now.isBefore(_startTime!)) return Duration.zero;
    return now.difference(_startTime!);
  }

  double get progress {
    if (_startTime == null || _targetTime == null) return 0.0;
    final total = _targetTime!.difference(_startTime!).inSeconds;
    final elapsed = timeElapsed.inSeconds;
    if (total <= 0) return 1.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  PrayerProvider() {
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (_coordinates != null) {
        _currentDay = DateTime.now().day;
        _calculateRamadanTimings();
      }
      _startTimer();
      notifyListeners();
    }
  }

  Future<void> init() async {
    try {
      if (_prayerTimes == null) {
        _isLoading = true;
        _city = _storageService.getCity() ?? "";
        notifyListeners();
      }
      _error = null;

      _notificationsEnabled = _storageService.getNotificationsEnabled();
      _suhoorAlarmOffset = _storageService.getSuhoorOffset();
      _iftarAlarmOffset = _storageService.getIftarOffset();
      _tahajjudAlarmOffset = _storageService.getTahajjudOffset();

      final savedMadhabIdx = _storageService.getMadhabIndex();
      if (savedMadhabIdx != null &&
          savedMadhabIdx >= 0 &&
          savedMadhabIdx < Madhab.values.length) {
        _madhab = Madhab.values[savedMadhabIdx];
      }

      final savedLang = _storageService.getLanguage();
      if (savedLang != null) {
        _locale = Locale(savedLang);
      } else {
        final String sysLang = Platform.localeName.split('_')[0];
        final supportedLanguages = ['en', 'ru', 'ar', 'tr', 'id', 'fr', 'ky', 'kk', 'uz', 'tg'];
        _locale = Locale(supportedLanguages.contains(sysLang) ? sysLang : 'en');
      }

      _isManualLocation = _storageService.getIsManualLocation();

      if (_isManualLocation) {
        final lat = _storageService.getManualLat();
        final lng = _storageService.getManualLng();
        if (lat != null && lng != null) {
          _coordinates = Coordinates(lat, lng);
          _city = _storageService.getCity() ?? "Selected City";
          _countryCode = _storageService.getCountryCode() ?? "";
        } else {
          _isManualLocation = false;
        }
      }

      if (!_isManualLocation) {
        final position = await _locationService.determinePosition();
        _coordinates = Coordinates(position.latitude, position.longitude);
        await _determineCityAndCountry(position.latitude, position.longitude);
      }

      // ИСПРАВЛЕНИЕ DEADLOCK'а: Безопасный запрос прав на пуши (Только ПОСЛЕ геолокации)
      await NotificationService().requestPermissions();

      final savedMethodIdx = _storageService.getCalculationMethodIndex();
      if (savedMethodIdx != null &&
          savedMethodIdx >= 0 &&
          savedMethodIdx < CalculationMethod.values.length) {
        _method = CalculationMethod.values[savedMethodIdx];
      } else {
        _method = _autoDetectMethod(_countryCode);
        await _storageService.saveCalculationMethodIndex(_method.index);
      }

      _currentDay = DateTime.now().day;
      _calculateRamadanTimings();
      _startTimer();
      await scheduleNotifications();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _mapErrorMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setManualLocation(String query) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<Location> locations = await locationFromAddress(query)
          .timeout(const Duration(seconds: 5));

      if (locations.isEmpty) {
        _error = "City not found. Please try another name.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final loc = locations.first;
      _coordinates = Coordinates(loc.latitude, loc.longitude);
      await _determineCityAndCountry(loc.latitude, loc.longitude,
          fallbackCity: query);

      _isManualLocation = true;
      _storageService.saveIsManualLocation(true);
      _storageService.saveManualLocation(
          loc.latitude, loc.longitude, _city, _countryCode);

      // ИСПРАВЛЕНИЕ: Также запрашиваем пуши, если юзер выбрал ручной поиск в первый раз
      await NotificationService().requestPermissions();

      _method = _autoDetectMethod(_countryCode);
      _storageService.saveCalculationMethodIndex(_method.index);

      _currentDay = DateTime.now().day;
      _calculateRamadanTimings();
      _startTimer();
      await scheduleNotifications();

      _isLoading = false;
      notifyListeners();
    } on TimeoutException {
      _error = "Network timeout. Check your connection.";
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "City not found. Please try another name.";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enableAutoLocation() async {
    _isManualLocation = false;
    _storageService.saveIsManualLocation(false);
    _isLoading = true;
    notifyListeners();
    await init();
  }

  void updateManualAdjustment(String prayerName, int minutes) {
    _storageService.saveAdjustment(prayerName, minutes);
    if (_coordinates != null) {
      _calculateRamadanTimings();
      scheduleNotifications();
      notifyListeners();
    }
  }

  CalculationParameters _getSmartParameters() {
    final params = _method.getParameters();
    params.madhab = _madhab;

    params.adjustments.fajr = _storageService.getAdjustment('fajr');
    params.adjustments.sunrise = _storageService.getAdjustment('sunrise');
    params.adjustments.dhuhr = _storageService.getAdjustment('dhuhr');
    params.adjustments.asr = _storageService.getAdjustment('asr');
    params.adjustments.maghrib = _storageService.getAdjustment('maghrib');
    params.adjustments.isha = _storageService.getAdjustment('isha');

    final double currentIshaAngle = params.ishaAngle ?? 0.0;
    params.highLatitudeRule = currentIshaAngle > 0.0
        ? HighLatitudeRule.twilight_angle
        : HighLatitudeRule.seventh_of_the_night;

    return params;
  }

  void _calculateRamadanTimings() {
    if (_coordinates == null) return;

    final now = DateTime.now();
    final params = _getSmartParameters();

    final todayTimes = PrayerTimes(_coordinates!, DateComponents.from(now), params);
    _prayerTimes = todayTimes;

    final fajrToday = todayTimes.fajr;
    final maghribToday = todayTimes.maghrib;

    if (now.isBefore(fajrToday)) {
      _currentEvent = RamadanEvent.suhoor;
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayTimes = PrayerTimes(_coordinates!, DateComponents.from(yesterday), params);

      _tahajjudTime = SunnahTimes(yesterdayTimes).lastThirdOfTheNight;
      _startTime = yesterdayTimes.maghrib;
      _targetTime = fajrToday;

    } else if (now.isBefore(maghribToday)) {
      _currentEvent = RamadanEvent.iftar;
      _tahajjudTime = SunnahTimes(todayTimes).lastThirdOfTheNight;
      _startTime = fajrToday;
      _targetTime = maghribToday;

    } else {
      _currentEvent = RamadanEvent.suhoor;
      _tahajjudTime = SunnahTimes(todayTimes).lastThirdOfTheNight;
      _startTime = maghribToday;
      final tomorrow = now.add(const Duration(days: 1));
      final tomorrowTimes = PrayerTimes(_coordinates!, DateComponents.from(tomorrow), params);
      _targetTime = tomorrowTimes.fajr;
    }
  }

  PrayerTimes? getPrayerTimesForDate(DateTime date) {
    if (_coordinates == null) return null;
    final params = _getSmartParameters();
    return PrayerTimes(_coordinates!, DateComponents.from(date), params);
  }

  void changeLanguage(String langCode) {
    if (_locale.languageCode == langCode) return;
    _locale = Locale(langCode);
    _storageService.saveLanguage(langCode);
    scheduleNotifications();
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _storageService.saveNotificationsEnabled(value);
    scheduleNotifications();
    notifyListeners();
  }

  void updateSuhoorAlarm(int minutes) {
    _suhoorAlarmOffset = minutes;
    _storageService.saveSuhoorOffset(minutes);
    scheduleNotifications();
    notifyListeners();
  }

  void updateIftarAlarm(int minutes) {
    _iftarAlarmOffset = minutes;
    _storageService.saveIftarOffset(minutes);
    scheduleNotifications();
    notifyListeners();
  }

  void updateTahajjudAlarm(int minutes) {
    _tahajjudAlarmOffset = minutes;
    _storageService.saveTahajjudOffset(minutes);
    scheduleNotifications();
    notifyListeners();
  }

  void updateCalculationMethod(CalculationMethod newMethod) {
    _method = newMethod;
    _storageService.saveCalculationMethodIndex(newMethod.index);
    if (_coordinates != null) {
      _calculateRamadanTimings();
      scheduleNotifications();
      notifyListeners();
    }
  }

  void updateMadhab(Madhab newMadhab) {
    _madhab = newMadhab;
    _storageService.saveMadhabIndex(newMadhab.index);
    if (_coordinates != null) {
      _calculateRamadanTimings();
      scheduleNotifications();
      notifyListeners();
    }
  }

  Future<void> scheduleNotifications() async {
    if (_isScheduling) {
      _needsReschedule = true;
      return;
    }
    _isScheduling = true;
    do {
      _needsReschedule = false;
      try {
        await NotificationService().cancelAll();
        if (!_notificationsEnabled || _coordinates == null) break;

        final now = DateTime.now();
        final String currentLang = _locale.languageCode;
        final params = _getSmartParameters();

        final List<PrayerTimes> calculationDays = [];

        for (int i = 0; i < 4; i++) {
          calculationDays.add(PrayerTimes(_coordinates!, DateComponents.from(now.add(Duration(days: i))), params));
        }

        final notificationService = NotificationService();
        int notificationIdBase = 0;

        for (var times in calculationDays) {
          final prayers = {
            notificationIdBase + 0: {'name': 'Fajr', 'time': times.fajr},
            notificationIdBase + 2: {'name': 'Dhuhr', 'time': times.dhuhr},
            notificationIdBase + 3: {'name': 'Asr', 'time': times.asr},
            notificationIdBase + 4: {'name': 'Maghrib', 'time': times.maghrib},
            notificationIdBase + 5: {'name': 'Isha', 'time': times.isha},
          };

          for (final entry in prayers.entries) {
            final id = entry.key;
            final data = entry.value;
            final String name = data['name'] as String;
            final DateTime time = data['time'] as DateTime;
            if (time.isAfter(now)) {
              final String title =
              NotificationDictionary.get('prayer_time_title', currentLang);
              final String body =
              NotificationDictionary.get('prayer_time_body', currentLang)
                  .replaceAll('{prayer}', name);
              await notificationService.schedulePrayerNotification(
                id: id,
                title: title,
                body: body,
                scheduledTime: time,
              );
            }
          }

          await _scheduleMotivationalPhases(
              times.fajr, times.maghrib, notificationIdBase);

          final suhoorWarning = times.fajr.subtract(const Duration(minutes: 5));
          if (suhoorWarning.isAfter(now)) {
            await notificationService.schedulePrayerNotification(
              id: notificationIdBase + 201,
              title:
              NotificationDictionary.get('suhoor_5min_title', currentLang),
              body: NotificationDictionary.get('suhoor_5min_body', currentLang),
              scheduledTime: suhoorWarning,
              payload: 'action_dua_suhoor',
            );
          }

          final iftarWarning =
          times.maghrib.subtract(const Duration(minutes: 5));
          if (iftarWarning.isAfter(now)) {
            await notificationService.schedulePrayerNotification(
              id: notificationIdBase + 202,
              title:
              NotificationDictionary.get('iftar_5min_title', currentLang),
              body: NotificationDictionary.get('iftar_5min_body', currentLang),
              scheduledTime: iftarWarning,
              payload: 'action_dua_iftar',
            );
          }

          if (_suhoorAlarmOffset > 0) {
            final suhoorAlarmTime =
            times.fajr.subtract(Duration(minutes: _suhoorAlarmOffset));
            if (suhoorAlarmTime.isAfter(now)) {
              await notificationService.schedulePrayerNotification(
                id: notificationIdBase + 301,
                title: NotificationDictionary.get(
                    'suhoor_smart_title', currentLang),
                body:
                NotificationDictionary.get('suhoor_smart_body', currentLang)
                    .replaceAll('{min}', _suhoorAlarmOffset.toString()),
                scheduledTime: suhoorAlarmTime,
              );
            }
          }

          if (_iftarAlarmOffset > 0) {
            final iftarAlarmTime =
            times.maghrib.subtract(Duration(minutes: _iftarAlarmOffset));
            if (iftarAlarmTime.isAfter(now)) {
              await notificationService.schedulePrayerNotification(
                id: notificationIdBase + 302,
                title: NotificationDictionary.get(
                    'iftar_smart_title', currentLang),
                body:
                NotificationDictionary.get('iftar_smart_body', currentLang)
                    .replaceAll('{min}', _iftarAlarmOffset.toString()),
                scheduledTime: iftarAlarmTime,
              );
            }
          }

          if (_tahajjudAlarmOffset > 0) {
            final sunnah = SunnahTimes(times);
            final tahajjudAlarmTime = sunnah.lastThirdOfTheNight
                .subtract(Duration(minutes: _tahajjudAlarmOffset));
            if (tahajjudAlarmTime.isAfter(now)) {
              await notificationService.schedulePrayerNotification(
                id: notificationIdBase + 303,
                title: NotificationDictionary.get(
                    'tahajjud_smart_title', currentLang),
                body: NotificationDictionary.get(
                    'tahajjud_smart_body', currentLang)
                    .replaceAll('{min}', _tahajjudAlarmOffset.toString()),
                scheduledTime: tahajjudAlarmTime,
              );
            }
          }
          notificationIdBase += 1000;
        }
      } catch (e) {
        debugPrint("Notification Scheduling Error: $e");
      }
    } while (_needsReschedule);
    _isScheduling = false;
  }

  Future<void> _scheduleMotivationalPhases(
      DateTime fajr, DateTime maghrib, int idOffset) async {
    final now = DateTime.now();
    final String currentLang = _locale.languageCode;
    final phases = [
      {'id': 10, 'h': 4, 't': 'phase1_title', 'b': 'phase1_body'},
      {'id': 11, 'h': 8, 't': 'phase2_title', 'b': 'phase2_body'},
      {'id': 12, 'h': 12, 't': 'phase3_title', 'b': 'phase3_body'},
      {'id': 13, 'h': 14, 't': 'phase4_title', 'b': 'phase4_body'}
    ];
    for (var phase in phases) {
      final scheduledTime = fajr.add(Duration(hours: phase['h'] as int));
      if (scheduledTime.isAfter(now) &&
          scheduledTime
              .isBefore(maghrib.subtract(const Duration(minutes: 30)))) {
        await NotificationService().schedulePrayerNotification(
          id: (phase['id'] as int) + idOffset,
          title: NotificationDictionary.get(phase['t'] as String, currentLang),
          body: NotificationDictionary.get(phase['b'] as String, currentLang),
          scheduledTime: scheduledTime,
        );
      }
    }
  }

  Future<void> _determineCityAndCountry(double lat, double lng,
      {String? fallbackCity}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 5));

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _city = place.locality ??
            place.administrativeArea ??
            fallbackCity ??
            "Location detected";
        _country = place.country ?? "";
        _countryCode = place.isoCountryCode ?? "";
        _storageService.saveCity(_city);
        _storageService.saveCountryCode(_countryCode);
      }
    } on TimeoutException {
      if (fallbackCity != null) {
        _city = fallbackCity;
      } else {
        _city = "Location Found";
      }
      debugPrint("Geocoding timeout gracefully handled");
    } catch (e) {
      if (fallbackCity != null) _city = fallbackCity;
      debugPrint("Geocoding error: $e");
    }
  }

  CalculationMethod _autoDetectMethod(String countryIso) {
    switch (countryIso.toUpperCase()) {
      case 'RU':
      case 'KG':
      case 'KZ':
      case 'UZ':
      case 'TJ':
        return CalculationMethod.muslim_world_league;
      case 'US':
      case 'CA':
      case 'GB':
        return CalculationMethod.north_america;
      case 'TR':
        return CalculationMethod.turkey;
      case 'SA':
        return CalculationMethod.umm_al_qura;
      default:
        return CalculationMethod.muslim_world_league;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_targetTime == null) return;
      final now = DateTime.now();
      if (now.day != _currentDay) {
        _currentDay = now.day;
        _calculateRamadanTimings();
        scheduleNotifications();
      }
      if (now.isAfter(_targetTime!)) {
        _calculateRamadanTimings();
        scheduleNotifications();
      } else {
        _timeRemaining = _targetTime!.difference(now);
        notifyListeners();
      }
    });
  }

  String _mapErrorMessage(dynamic e) {
    final error = e.toString().toLowerCase();
    if (error.contains("disabled") || error.contains("отключ")) {
      return "Location services are disabled. Tap here to set city manually.";
    }
    if (error.contains("denied") ||
        error.contains("отказ") ||
        error.contains("заблок")) {
      return "Location permission denied. Tap here to set city manually.";
    }
    return "Check connection or set city manually.";
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}