class DuaCategory {
  final String id; // Например: 'ramadan', 'morning', 'protection'
  final String iconPath; // Или просто IconData, если используем иконки Flutter
  final List<DuaItem> duas;

  DuaCategory({
    required this.id,
    required this.iconPath,
    required this.duas,
  });
}

class DuaItem {
  final String id;
  final String arabicText;
  final String transcription; // Транслитерация (латиница/кириллица)
  final String source; // Откуда взято (Коран, Муслим, Бухари)

  DuaItem({
    required this.id,
    required this.arabicText,
    required this.transcription,
    required this.source,
  });
}