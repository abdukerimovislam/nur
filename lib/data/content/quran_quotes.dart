class LocalizedQuranText {
  const LocalizedQuranText({
    required this.text,
    required this.reference,
  });

  final String text;
  final String reference;
}

class QuranQuote {
  const QuranQuote({
    required this.id,
    required this.translations,
    required this.duaByLanguage,
  });

  final String id;
  final Map<String, LocalizedQuranText> translations;
  final Map<String, String> duaByLanguage;

  LocalizedQuranText textFor(String languageCode) {
    return translations[languageCode] ??
        translations[_baseLanguage(languageCode)] ??
        translations['en']!;
  }

  String duaFor(String languageCode) {
    return duaByLanguage[languageCode] ??
        duaByLanguage[_baseLanguage(languageCode)] ??
        duaByLanguage['en']!;
  }

  static String _baseLanguage(String languageCode) {
    return languageCode.split(RegExp('[-_]')).first.toLowerCase();
  }
}

class DailyQuranContent {
  const DailyQuranContent({
    required this.text,
    required this.reference,
    required this.dua,
  });

  final String text;
  final String reference;
  final String dua;
}

class QuranQuotesRepository {
  const QuranQuotesRepository._();

  static DailyQuranContent dailyContent({
    required DateTime date,
    required String languageCode,
  }) {
    final quote = quoteForDate(date);
    final localized = quote.textFor(languageCode);

    return DailyQuranContent(
      text: localized.text,
      reference: localized.reference,
      dua: quote.duaFor(languageCode),
    );
  }

  static QuranQuote quoteForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return quotes[dayOfYear % quotes.length];
  }

  static const List<QuranQuote> quotes = [
    QuranQuote(
      id: 'quran_2_152_remembrance',
      translations: {
        'en': LocalizedQuranText(
          text: 'So remember Me; I will remember you.',
          reference: 'Quran 2:152',
        ),
        'ru': LocalizedQuranText(
          text: 'Поминайте Меня, и Я буду помнить о вас.',
          reference: 'Коран 2:152',
        ),
        'ar': LocalizedQuranText(
          text: 'فَاذْكُرُونِي أَذْكُرْكُمْ',
          reference: 'القرآن 2:152',
        ),
      },
      duaByLanguage: {
        'en': 'O Allah, guide my heart and make prayer beloved to me.',
        'ru': 'О Аллах, направь мое сердце и сделай намаз любимым для меня.',
        'ar': 'اللهم اهد قلبي وحبب إلي الصلاة.',
      },
    ),
    QuranQuote(
      id: 'quran_40_60_dua',
      translations: {
        'en': LocalizedQuranText(
          text: 'Call upon Me; I will respond to you.',
          reference: 'Quran 40:60',
        ),
        'ru': LocalizedQuranText(
          text: 'Взывайте ко Мне, и Я отвечу вам.',
          reference: 'Коран 40:60',
        ),
        'ar': LocalizedQuranText(
          text: 'ادْعُونِي أَسْتَجِبْ لَكُمْ',
          reference: 'القرآن 40:60',
        ),
      },
      duaByLanguage: {
        'en': 'O Allah, open the doors of mercy for me.',
        'ru': 'О Аллах, открой для меня двери Своей милости.',
        'ar': 'اللهم افتح لي أبواب رحمتك.',
      },
    ),
    QuranQuote(
      id: 'quran_13_28_hearts_rest',
      translations: {
        'en': LocalizedQuranText(
          text: 'In the remembrance of Allah hearts find rest.',
          reference: 'Quran 13:28',
        ),
        'ru': LocalizedQuranText(
          text: 'Разве не поминанием Аллаха успокаиваются сердца?',
          reference: 'Коран 13:28',
        ),
        'ar': LocalizedQuranText(
          text: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
          reference: 'القرآن 13:28',
        ),
      },
      duaByLanguage: {
        'en': 'O Allah, fill my tongue with dhikr and gratitude.',
        'ru': 'О Аллах, наполни мой язык поминанием и благодарностью.',
        'ar': 'اللهم املأ لساني بذكرك وشكرك.',
      },
    ),
    QuranQuote(
      id: 'quran_2_153_patience',
      translations: {
        'en': LocalizedQuranText(
          text: 'Indeed, Allah is with the patient.',
          reference: 'Quran 2:153',
        ),
        'ru': LocalizedQuranText(
          text: 'Воистину, Аллах с терпеливыми.',
          reference: 'Коран 2:153',
        ),
        'ar': LocalizedQuranText(
          text: 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
          reference: 'القرآن 2:153',
        ),
      },
      duaByLanguage: {
        'en': 'O Allah, grant me patience and a steady heart.',
        'ru': 'О Аллах, даруй мне терпение и стойкое сердце.',
        'ar': 'اللهم ارزقني الصبر وثبات القلب.',
      },
    ),
    QuranQuote(
      id: 'quran_57_4_nearness',
      translations: {
        'en': LocalizedQuranText(
          text: 'And He is with you wherever you are.',
          reference: 'Quran 57:4',
        ),
        'ru': LocalizedQuranText(
          text: 'Он с вами, где бы вы ни были.',
          reference: 'Коран 57:4',
        ),
        'ar': LocalizedQuranText(
          text: 'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
          reference: 'القرآن 57:4',
        ),
      },
      duaByLanguage: {
        'en': 'O Allah, keep me aware of Your nearness.',
        'ru': 'О Аллах, помоги мне помнить о Твоей близости.',
        'ar': 'اللهم اجعلني دائم الشعور بقربك.',
      },
    ),
  ];
}
