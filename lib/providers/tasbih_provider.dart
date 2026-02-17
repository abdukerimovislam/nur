import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/services/preferences_service.dart';

class TasbihProvider extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();
  static const int _dhikrCount = 4;

  int _count = 0;
  int _selectedDhikrIndex = 0; // Индекс выбранного зикра

  int get count => _count;
  int get selectedDhikrIndex => _selectedDhikrIndex;

  TasbihProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _count = await _prefs.loadTasbihCount();
    // Загружаем сохраненный индекс зикра при старте приложения
    final loadedIndex = await _prefs.loadTasbihIndex();
    if (loadedIndex >= 0 && loadedIndex < _dhikrCount) {
      _selectedDhikrIndex = loadedIndex;
    } else {
      _selectedDhikrIndex = 0;
      _prefs.saveTasbihIndex(0);
    }
    notifyListeners();
  }

  void increment() {
    _count++;
    HapticFeedback.mediumImpact();
    _prefs.saveTasbihCount(_count);
    notifyListeners();
  }

  void reset() {
    _count = 0;
    HapticFeedback.vibrate();
    _prefs.saveTasbihCount(0);
    notifyListeners();
  }

  // Метод выбора зикра
  void selectDhikr(int index) {
    if (index < 0 || index >= _dhikrCount) return;
    if (_selectedDhikrIndex != index) {
      _selectedDhikrIndex = index;
      _count = 0; // Сбрасываем счетчик при выборе нового зикра
      HapticFeedback.lightImpact();

      // Сохраняем новый индекс и обнуленный счетчик в память
      _prefs.saveTasbihIndex(index);
      _prefs.saveTasbihCount(0);

      notifyListeners();
    }
  }
}
