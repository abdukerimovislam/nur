import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/services/preferences_service.dart';

class TasbihProvider extends ChangeNotifier with WidgetsBindingObserver {
  final PreferencesService _prefs = PreferencesService();

  int _count = 0;
  int _selectedDhikrIndex = 0;

  // Таймер для дебаунса сохранения в память
  Timer? _debounceTimer;

  int get count => _count;
  int get selectedDhikrIndex => _selectedDhikrIndex;

  TasbihProvider() {
    // Подписываемся на события жизненного цикла ОС
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ЖЕЛЕЗОБЕТОННАЯ ЗАЩИТА: Если приложение сворачивают или убивают,
    // мгновенно сохраняем данные, не дожидаясь окончания таймера.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_debounceTimer?.isActive ?? false) {
        _debounceTimer?.cancel();
        _prefs.saveTasbihCount(_count);
      }
    }
  }

  Future<void> _loadData() async {
    _count = await _prefs.loadTasbihCount();
    _selectedDhikrIndex = await _prefs.loadTasbihIndex();
    notifyListeners();
  }

  void increment() {
    _count++;
    HapticFeedback.mediumImpact();
    notifyListeners();

    // Сбрасываем таймер и сохраняем данные в память только когда юзер перестанет кликать
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _prefs.saveTasbihCount(_count);
    });
  }

  void reset() {
    _count = 0;
    HapticFeedback.vibrate();
    notifyListeners();

    _debounceTimer?.cancel();
    _prefs.saveTasbihCount(0);
  }

  void selectDhikr(int index) {
    if (_selectedDhikrIndex != index) {
      _selectedDhikrIndex = index;
      _count = 0;
      HapticFeedback.lightImpact();

      _debounceTimer?.cancel();
      _prefs.saveTasbihIndex(index);
      _prefs.saveTasbihCount(0);

      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    super.dispose();
  }
}