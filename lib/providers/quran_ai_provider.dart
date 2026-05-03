import 'package:flutter/foundation.dart';

import '../data/services/storage_service.dart';

class QuranAIProvider extends ChangeNotifier {
  QuranAIProvider() {
    _load();
  }

  static const String _checksKey = 'nur_quran_ai_checks_v1';
  static const String _dateKey = 'nur_quran_ai_checks_date_v1';

  final StorageService _storage = StorageService();

  bool _isLoading = true;
  int _checksUsedToday = 0;
  DateTime _currentDate = DateTime.now();

  bool get isLoading => _isLoading;

  int get freeDailyLimit => 3;

  int get checksUsedToday => _checksUsedToday;

  int get checksRemainingToday {
    final remaining = freeDailyLimit - _checksUsedToday;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canUseFreeCheck => checksRemainingToday > 0;

  double get freeLimitProgress {
    return (_checksUsedToday / freeDailyLimit).clamp(0.0, 1.0);
  }

  Future<void> consumeFreeCheck() async {
    _ensureToday();

    if (!canUseFreeCheck) return;

    _checksUsedToday++;
    notifyListeners();
    await _save();
  }

  Future<void> resetForTesting() async {
    _checksUsedToday = 0;
    _currentDate = DateTime.now();
    notifyListeners();
    await _save();
  }

  void _load() {
    _isLoading = true;

    final storedDate = _storage.getString(_dateKey);
    final storedChecks = _storage.getInt(_checksKey) ?? 0;

    final parsedDate = storedDate == null ? null : DateTime.tryParse(storedDate);

    if (parsedDate == null || !_isSameDay(parsedDate, DateTime.now())) {
      _currentDate = DateTime.now();
      _checksUsedToday = 0;
      _save();
    } else {
      _currentDate = parsedDate;
      _checksUsedToday = storedChecks;
    }

    _isLoading = false;
    notifyListeners();
  }

  void _ensureToday() {
    final now = DateTime.now();

    if (!_isSameDay(_currentDate, now)) {
      _currentDate = now;
      _checksUsedToday = 0;
    }
  }

  Future<void> _save() async {
    await _storage.saveString(
      _dateKey,
      DateTime(
        _currentDate.year,
        _currentDate.month,
        _currentDate.day,
      ).toIso8601String(),
    );
    await _storage.saveInt(_checksKey, _checksUsedToday);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}