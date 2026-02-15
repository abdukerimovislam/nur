import '../../l10n/app_localizations.dart';

class DuaRepository {
  static List<Map<String, String>> getDuasByCategory(String categoryId, AppLocalizations l10n) {
    switch (categoryId) {
      case 'ramadan':
        return [
          {
            'title': l10n.duaSuhoorTitle,
            'arabic': l10n.duaSuhoorArabic,
            'trans': l10n.duaSuhoorTrans,
            'translate': l10n.duaSuhoorTranslate,
          },
          {
            'title': l10n.duaIftarTitle,
            'arabic': l10n.duaIftarArabic,
            'trans': l10n.duaIftarTrans,
            'translate': l10n.duaIftarTranslate,
          },
          {
            'title': l10n.dua_qadr_title,
            'arabic': l10n.dua_qadr_ar,
            'trans': l10n.dua_qadr_trans,
            'translate': l10n.dua_qadr_text,
          },
        ];
      case 'after_salah':
        return [
          {
            'title': l10n.dua_kursi_title,
            'arabic': l10n.dua_kursi_ar,
            'trans': l10n.dua_kursi_trans,
            'translate': l10n.dua_kursi_text,
          },
        ];
      case 'morning_evening':
        return [
          {
            'title': l10n.dua_morning_title,
            'arabic': l10n.dua_morning_ar,
            'trans': l10n.dua_morning_trans,
            'translate': l10n.dua_morning_text,
          },
        ];
      case 'forgiveness':
        return [
          {
            'title': l10n.dua_istighfar_title,
            'arabic': l10n.dua_istighfar_ar,
            'trans': l10n.dua_istighfar_trans,
            'translate': l10n.dua_istighfar_text,
          },
        ];
      case 'protection': // Наша категория "От тревоги"
        return [
          {
            'title': l10n.dua_sadness_title,
            'arabic': l10n.dua_sadness_ar,
            'trans': l10n.dua_sadness_trans,
            'translate': l10n.dua_sadness_text,
          },
        ];
      default:
        return [];
    }
  }
}