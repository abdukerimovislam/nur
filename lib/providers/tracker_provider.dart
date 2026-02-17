import 'package:flutter/material.dart';
import '../data/services/storage_service.dart';

// Строгая типизация статусов дня
enum FastingStatus {
  none,    // День еще не наступил или не отмечен
  fasted,  // Держал пост
  missed,  // Пропустил (Каза - нужно восполнить)
}

class TrackerProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  // Кэш в оперативной памяти для мгновенного доступа
  Map<String, FastingStatus> _fastingDays = {};

  bool _isLoading = true;

  // --- Getters ---
  bool get isLoading => _isLoading;
  Map<String, FastingStatus> get fastingDays => _fastingDays;

  // Статистика для UI
  int get fastedCount => _fastingDays.values.where((s) => s == FastingStatus.fasted).length;
  int get missedCount => _fastingDays.values.where((s) => s == FastingStatus.missed).length;

  TrackerProvider() {
    _loadData();
  }

  // Форматируем дату в строгий ключ YYYY-MM-DD
  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _loadData() {
    _isLoading = true;

    // Читаем данные мгновенно из оперативной памяти StorageService
    final rawData = _storage.getFastingData();

    // Конвертируем строки из БД обратно в Enum
    _fastingDays = rawData.map((key, value) {
      FastingStatus status = FastingStatus.none;
      if (value == 'fasted') status = FastingStatus.fasted;
      if (value == 'missed') status = FastingStatus.missed;
      return MapEntry(key, status);
    });

    _isLoading = false;
    notifyListeners();
  }

  // --- МЕТОД ДЛЯ 3-Х КНОПОК ---
  Future<void> setDayStatus(DateTime date, FastingStatus newStatus) async {
    // ИСПРАВЛЕНИЕ: Железобетонная защита бэкенда от будущих дат!
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    if (checkDate.isAfter(today)) return;

    final key = _formatDateKey(date);

    if (newStatus == FastingStatus.none) {
      _fastingDays.remove(key);
    } else {
      _fastingDays[key] = newStatus;
    }

    notifyListeners();
    _saveData();
  }

  // Метод переключения статуса по тапу на день в календаре
  Future<void> toggleDayStatus(DateTime date) async {
    // ИСПРАВЛЕНИЕ: Защита бэкенда при переключении тапом
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    if (checkDate.isAfter(today)) return;

    final key = _formatDateKey(date);
    final currentStatus = _fastingDays[key] ?? FastingStatus.none;

    // Логика переключения: none -> fasted -> missed -> none
    FastingStatus newStatus;
    switch (currentStatus) {
      case FastingStatus.none:
        newStatus = FastingStatus.fasted;
        break;
      case FastingStatus.fasted:
        newStatus = FastingStatus.missed;
        break;
      case FastingStatus.missed:
        newStatus = FastingStatus.none;
        break;
    }

    if (newStatus == FastingStatus.none) {
      _fastingDays.remove(key);
    } else {
      _fastingDays[key] = newStatus;
    }

    notifyListeners();
    _saveData();
  }

  // Утилита для получения статуса конкретного дня
  FastingStatus getStatusForDate(DateTime date) {
    final key = _formatDateKey(date);
    return _fastingDays[key] ?? FastingStatus.none;
  }

  Future<void> _saveData() async {
    final Map<String, String> dataToSave = _fastingDays.map((key, value) {
      return MapEntry(key, value.name);
    });

    await _storage.saveFastingData(dataToSave);
  }
}