import 'package:flutter/foundation.dart';
import '../data/services/storage_service.dart';

enum PrayerName {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

extension PrayerNameX on PrayerName {
  String get storageKey {
    switch (this) {
      case PrayerName.fajr:
        return 'fajr';
      case PrayerName.dhuhr:
        return 'dhuhr';
      case PrayerName.asr:
        return 'asr';
      case PrayerName.maghrib:
        return 'maghrib';
      case PrayerName.isha:
        return 'isha';
    }
  }

  String get englishName {
    switch (this) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }
}

class PrayerDayStats {
  const PrayerDayStats({
    required this.completedCount,
    required this.totalCount,
    required this.completionPercent,
  });

  final int completedCount;
  final int totalCount;
  final double completionPercent;
}

class PrayerTrackerProvider extends ChangeNotifier {
  PrayerTrackerProvider() {
    _load();
  }

  static const String _storagePrefix = 'nur_prayer_tracker_v1';

  final StorageService _storage = StorageService();

  final Map<String, Set<PrayerName>> _completedPrayersByDate = {};
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Map<String, Set<PrayerName>> get completedPrayersByDate =>
      Map.unmodifiable(_completedPrayersByDate);

  List<PrayerName> get prayerOrder => const [
    PrayerName.fajr,
    PrayerName.dhuhr,
    PrayerName.asr,
    PrayerName.maghrib,
    PrayerName.isha,
  ];

  String dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }

  bool isPrayerCompleted(DateTime date, PrayerName prayer) {
    final key = dateKey(date);
    return _completedPrayersByDate[key]?.contains(prayer) ?? false;
  }

  Future<void> togglePrayer(DateTime date, PrayerName prayer) async {
    final key = dateKey(date);
    final current = _completedPrayersByDate[key] ?? <PrayerName>{};

    if (current.contains(prayer)) {
      current.remove(prayer);
    } else {
      current.add(prayer);
    }

    if (current.isEmpty) {
      _completedPrayersByDate.remove(key);
    } else {
      _completedPrayersByDate[key] = current;
    }

    notifyListeners();
    await _save();
  }

  Future<void> markPrayerCompleted(DateTime date, PrayerName prayer) async {
    final key = dateKey(date);
    final current = _completedPrayersByDate[key] ?? <PrayerName>{};

    if (!current.contains(prayer)) {
      current.add(prayer);
      _completedPrayersByDate[key] = current;
      notifyListeners();
      await _save();
    }
  }

  Future<void> unmarkPrayer(DateTime date, PrayerName prayer) async {
    final key = dateKey(date);
    final current = _completedPrayersByDate[key];

    if (current == null || !current.contains(prayer)) return;

    current.remove(prayer);

    if (current.isEmpty) {
      _completedPrayersByDate.remove(key);
    } else {
      _completedPrayersByDate[key] = current;
    }

    notifyListeners();
    await _save();
  }

  PrayerDayStats getStatsForDate(DateTime date) {
    final key = dateKey(date);
    final completedCount = _completedPrayersByDate[key]?.length ?? 0;
    const totalCount = 5;

    return PrayerDayStats(
      completedCount: completedCount,
      totalCount: totalCount,
      completionPercent: completedCount / totalCount,
    );
  }

  int get currentStreak {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 3650; i++) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final stats = getStatsForDate(date);

      if (stats.completedCount == 5) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int get bestStreak {
    if (_completedPrayersByDate.isEmpty) return 0;

    final sortedDates = _completedPrayersByDate.keys.toList()..sort();

    int best = 0;
    int current = 0;
    DateTime? previousDate;

    for (final key in sortedDates) {
      final date = DateTime.tryParse(key);
      if (date == null) continue;

      final stats = getStatsForDate(date);
      final isPerfectDay = stats.completedCount == 5;

      if (!isPerfectDay) {
        current = 0;
        previousDate = date;
        continue;
      }

      if (previousDate == null) {
        current = 1;
      } else {
        final expectedNextDay = DateTime(
          previousDate.year,
          previousDate.month,
          previousDate.day + 1,
        );

        if (date.year == expectedNextDay.year &&
            date.month == expectedNextDay.month &&
            date.day == expectedNextDay.day) {
          current++;
        } else {
          current = 1;
        }
      }

      if (current > best) best = current;
      previousDate = date;
    }

    return best;
  }

  PrayerName? get weakestPrayer {
    if (_completedPrayersByDate.isEmpty) return null;

    final Map<PrayerName, int> completedCounts = {
      for (final prayer in prayerOrder) prayer: 0,
    };

    for (final prayers in _completedPrayersByDate.values) {
      for (final prayer in prayers) {
        completedCounts[prayer] = (completedCounts[prayer] ?? 0) + 1;
      }
    }

    PrayerName? weakest;
    int? lowestCount;

    for (final entry in completedCounts.entries) {
      if (lowestCount == null || entry.value < lowestCount) {
        weakest = entry.key;
        lowestCount = entry.value;
      }
    }

    return weakest;
  }

  double get weeklyCompletionPercent {
    final today = DateTime.now();
    int completed = 0;
    const total = 7 * 5;

    for (int i = 0; i < 7; i++) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      completed += getStatsForDate(date).completedCount;
    }

    return completed / total;
  }

  Future<void> _load() async {
    _isLoading = true;

    try {
      final raw = _storage.getStringList(_storagePrefix) ?? <String>[];

      _completedPrayersByDate.clear();

      for (final item in raw) {
        final parts = item.split('|');
        if (parts.length != 2) continue;

        final key = parts[0];
        final prayerKey = parts[1];

        final prayer = _prayerFromStorageKey(prayerKey);
        if (prayer == null) continue;

        final current = _completedPrayersByDate[key] ?? <PrayerName>{};
        current.add(prayer);
        _completedPrayersByDate[key] = current;
      }
    } catch (_) {
      _completedPrayersByDate.clear();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final raw = <String>[];

    for (final entry in _completedPrayersByDate.entries) {
      for (final prayer in entry.value) {
        raw.add('${entry.key}|${prayer.storageKey}');
      }
    }

    await _storage.saveStringList(_storagePrefix, raw);
  }

  PrayerName? _prayerFromStorageKey(String key) {
    for (final prayer in PrayerName.values) {
      if (prayer.storageKey == key) return prayer;
    }
    return null;
  }
}