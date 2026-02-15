import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';

class DailyInspirationCard extends StatelessWidget {
  const DailyInspirationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Простая логика ротации: меняем карточку каждый день
    // Если у нас 3 цитаты, берем остаток от деления на 3.
    final int quoteIndex = DateTime.now().day % 3;

    // Вытаскиваем нужные строки через switch,
    // так как l10n не поддерживает динамические ключи вида l10n['quote_$index']
    String arabicText = '';
    String translatedText = '';
    String source = '';

    switch (quoteIndex) {
      case 0:
        arabicText = l10n.quote1_ar;
        translatedText = l10n.quote1_text;
        source = l10n.quote1_source;
        break;
      case 1:
        arabicText = l10n.quote2_ar;
        translatedText = l10n.quote2_text;
        source = l10n.quote2_source;
        break;
      case 2:
      default:
        arabicText = l10n.quote3_ar;
        translatedText = l10n.quote3_text;
        source = l10n.quote3_source;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Заголовок карточки
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.dailyInspiration.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Арабский текст (Оригинал)
          Text(
            arabicText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl, // Строго справа-налево для арабского
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.6,
              fontWeight: FontWeight.w600,
              fontFamily: 'Amiri', // Идеально, если у тебя подключен арабский шрифт, иначе системный
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, thickness: 1),
          ),

          // Перевод на язык приложения
          Text(
            translatedText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // Источник (Коран / Бухари и т.д.)
          Text(
            "— $source",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}