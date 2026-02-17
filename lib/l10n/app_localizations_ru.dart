// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Nur';

  @override
  String get appName => 'NUR';

  @override
  String get appSubtitle => 'ПОМОЩНИК В РАМАДАН';

  @override
  String get loading => 'Вычисление времени...';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get locationDetecting => 'Определение геолокации...';

  @override
  String get locationError => 'Геолокация недоступна';

  @override
  String get errorLocation => 'Не удалось определить местоположение';

  @override
  String get locationPermissionText => 'Доступ к геолокации необходим для точного расчета времени молитв.';

  @override
  String get timeLeftIftar => 'Время до Ифтара';

  @override
  String get timeLeftSuhoor => 'Время до Сухура';

  @override
  String get timeRemaining => 'Осталось до молитвы';

  @override
  String get untilSuhoor => 'до Сухура';

  @override
  String get untilIftar => 'до Ифтара';

  @override
  String get suhoor => 'Сухур';

  @override
  String get iftar => 'Ифтар';

  @override
  String get fajr => 'Фаджр';

  @override
  String get sunrise => 'Восход';

  @override
  String get dhuhr => 'Зухр';

  @override
  String get asr => 'Аср';

  @override
  String get maghrib => 'Магриб';

  @override
  String get isha => 'Иша';

  @override
  String get tahajjud => 'Тахаджуд';

  @override
  String get qiblaTitle => 'Кибла';

  @override
  String get qiblaDirection => 'Направление Киблы';

  @override
  String get qiblaSearching => 'ПОИСК';

  @override
  String get qiblaAligned => 'КИБЛА НАЙДЕНА';

  @override
  String get holyKaaba => 'СВЯЩЕННАЯ КААБА';

  @override
  String get rotatePhone => 'Положите телефон на плоскую поверхность';

  @override
  String get calibrateCompass => 'Сделайте движение телефоном в виде цифры 8';

  @override
  String get north => 'С';

  @override
  String get navHome => 'Главная';

  @override
  String get navQibla => 'Кибла';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get calendarHeader => 'Календарь Рамадана';

  @override
  String get hijriDate => 'Дата по Хиджре';

  @override
  String get refresh => 'Обновить';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get generalSection => 'Основные';

  @override
  String get languageSection => 'Язык';

  @override
  String get language => 'Язык';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String get calculationMethod => 'Метод расчета';

  @override
  String get madhab => 'Мазхаб (для Асра)';

  @override
  String get location => 'Локация';

  @override
  String get searchCityManually => 'Выбрать город вручную';

  @override
  String get changeLocation => 'Изменить локацию';

  @override
  String get enterCityHint => 'Введите город (напр. Москва)';

  @override
  String get searchBtn => 'Найти';

  @override
  String get useAutoLocation => 'Вернуть авто-определение (GPS)';

  @override
  String get notificationsSection => 'Уведомления';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get enableNotifications => 'Push-уведомления';

  @override
  String get enableNotificationsDesc => 'Напоминания за 5 минут до сухура и ифтара';

  @override
  String get smartAlarms => 'Умные будильники';

  @override
  String get smartAlarmsDesc => 'Автоматически подстраиваются под время сухура и ифтара.';

  @override
  String get suhoorAlarm => 'Пробуждение на Сухур';

  @override
  String get iftarAlarm => 'Подготовка к Ифтару';

  @override
  String get tahajjudAlarm => 'Будильник Тахаджуда';

  @override
  String get alarmOff => 'Выкл';

  @override
  String get alarm20Min => 'За 20 мин';

  @override
  String get alarm30Min => 'За 30 мин';

  @override
  String get alarm60Min => 'За 1 час';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get madhabHanafi => 'Ханафитский';

  @override
  String get madhabStandard => 'Стандартный (Шафии, Малики, Ханбали)';

  @override
  String get methodMWL => 'Всемирная исламская лига';

  @override
  String get methodISNA => 'ISNA (Северная Америка)';

  @override
  String get methodEgypt => 'Управление Египта';

  @override
  String get methodMakkah => 'Умм аль-Кура (Мекка)';

  @override
  String get methodKarachi => 'Карачи (Исламский университет)';

  @override
  String get methodTehran => 'Институт геофизики (Тегеран)';

  @override
  String get methodTurkey => 'Диянет (Турция)';

  @override
  String get methodSingapore => 'Сингапур (MUIS)';

  @override
  String get methodOther => 'Другой / Пользовательский';

  @override
  String get onboardTitle1 => 'Добро пожаловать в NUR';

  @override
  String get onboardDesc1 => 'Ваш премиальный помощник в Священный месяц Рамадан. Минималистичный, точный и без рекламы.';

  @override
  String get onboardTitle2 => 'Точное время';

  @override
  String get onboardDesc2 => 'Чтобы рассчитать точное время сухура и ифтара для вашего региона, нам нужен доступ к геоданным.';

  @override
  String get onboardTitle3 => 'Не упустите момент';

  @override
  String get onboardDesc3 => 'Разрешите уведомления, чтобы мы могли мягко напомнить вам за 5 минут до сухура и ифтара.';

  @override
  String get next => 'Далее';

  @override
  String get getStarted => 'Начать';

  @override
  String get bioTitle => 'Состояние тела';

  @override
  String get bioNightTitle => 'Восстановление';

  @override
  String get bioNightDesc => 'Ваше тело отдыхает. Пейте больше воды для подготовки к посту.';

  @override
  String get bioPhase1Title => 'Снижение сахара';

  @override
  String get bioPhase1Desc => 'Уровень сахара падает. Снижается выработка инсулина.';

  @override
  String get bioPhase2Title => 'Отдых ЖКТ';

  @override
  String get bioPhase2Desc => 'Пищеварение завершено. Организм берет энергию из запасов гликогена.';

  @override
  String get bioPhase3Title => 'Сжигание жира (Кетоз)';

  @override
  String get bioPhase3Desc => 'Гликоген исчерпан. Тело начинает сжигать жировые запасы для энергии.';

  @override
  String get bioPhase4Title => 'Детоксикация (Аутофагия)';

  @override
  String get bioPhase4Desc => 'Организм очищается от поврежденных клеток и обновляется.';

  @override
  String get fastingProgress => 'Прогресс поста';

  @override
  String get fastingStatus => 'Статус поста';

  @override
  String get statusFasted => 'Держал(а)';

  @override
  String get statusMissed => 'Пропустил(а)';

  @override
  String get statusNotSet => 'Не отмечено';

  @override
  String get futureDateError => 'Нельзя отмечать статус для будущих дней';

  @override
  String shareProgress(int fasted, int missed) {
    return 'Мой прогресс в Рамадан 🌙\nДней поста: $fasted\nПропущено (Каза): $missed\nОтслежено в приложении NUR!';
  }

  @override
  String get shareImageTitle => 'Мой Рамадан';

  @override
  String get shareImageDays => 'Дней поста';

  @override
  String get shareImageApp => 'Приложение NUR';

  @override
  String get tasbihTitle => 'Тасбих';

  @override
  String get reset => 'Сбросить';

  @override
  String get total => 'Всего';

  @override
  String get subhanAllah => 'Субханаллах';

  @override
  String get alhamdulillah => 'Альхамдулиллях';

  @override
  String get allahuAkbar => 'Аллаху Акбар';

  @override
  String get astaghfirullah => 'Астагфируллах';

  @override
  String get resetConfirm => 'Вы уверены, что хотите обнулить счетчик?';

  @override
  String get resetAction => 'Сбросить';

  @override
  String get dailyInspiration => 'Вдохновение дня';

  @override
  String get quote1_ar => 'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ';

  @override
  String get quote1_text => 'О те, которые уверовали! Вам предписан пост, подобно тому, как он был предписан вашим предшественникам, — быть может, вы устрашитесь.';

  @override
  String get quote1_source => 'Коран, Аль-Бакара (2:183)';

  @override
  String get quote2_ar => 'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ';

  @override
  String get quote2_text => 'Тому, кто постился в Рамадан с верой и надеждой на награду Аллаха, простятся его прежние грехи.';

  @override
  String get quote2_source => 'Сахих аль-Бухари (38)';

  @override
  String get quote3_ar => 'لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ';

  @override
  String get quote3_text => 'Ночь Предопределения лучше тысячи месяцев.';

  @override
  String get quote3_source => 'Коран, Аль-Кадр (97:3)';

  @override
  String get duaLibraryTitle => 'Библиотека Дуа';

  @override
  String get categoryRamadan => 'Рамадан';

  @override
  String get categoryMorningEvening => 'Утро и Вечер';

  @override
  String get categoryAfterSalah => 'После намаза';

  @override
  String get categoryProtection => 'Защита';

  @override
  String get categoryForgiveness => 'Прощение';

  @override
  String get categoryFamily => 'Семья и дети';

  @override
  String get transcription => 'Транскрипция';

  @override
  String get translation => 'Перевод';

  @override
  String get copied => 'Скопировано в буфер';

  @override
  String get tapForDua => 'Нажмите для Дуа';

  @override
  String get duaSuhoorTitle => 'Дуа для Сухура (Намерение)';

  @override
  String get duaSuhoorArabic => 'نَوَيْتُ أَنْ أَصُومَ صَوْمَ شَهْرِ رَمَضَانَ مِنَ الْفَجْرِ إِلَى الْمَغْرِبِ خَالِصًا لِلَّهِ تَعَالَى';

  @override
  String get duaSuhoorTranslit => 'Навайту ан асума савма шахри рамадана миналь фаджри иляль магриби халисан лилляхи та\'аля.';

  @override
  String get duaSuhoorTransl => 'Я намерился держать пост месяца Рамадан от рассвета до заката ради Аллаха.';

  @override
  String get duaSuhoorTrans => 'Навайту ан асума савма шахри рамадана миналь фаджри иляль магриби халисан лилляхи та\'аля';

  @override
  String get duaSuhoorTranslate => 'Я намерился держать пост завтрашнего дня месяца Рамадан искренне ради Аллаха.';

  @override
  String get duaIftarTitle => 'Дуа для Ифтара (Разговение)';

  @override
  String get duaIftarArabic => 'اللَّهُمَّ اِنِّى لَكَ صُمْتُ وَبِكَ امَنْتُ وَعَليْكَ تَوَكَّلْتُ وَعَلى رِزْقِكَ اَفْطَرْتُ';

  @override
  String get duaIftarTranslit => 'Аллахумма инни ляка сумту ва бика аманту ва ‘аляйка таваккальту ва ‘аля ризкика афтарту.';

  @override
  String get duaIftarTransl => 'О Аллах, ради Тебя я постился, в Тебя уверовал, на Тебя положился и Твоим уделом разговелся.';

  @override
  String get duaIftarTrans => 'Захаба-ззама’у вабталлятиль-‘уруку ва сабаталь-аджру ин ша’а-Ллах';

  @override
  String get duaIftarTranslate => 'Жажда ушла, жилы наполнились влагой, и награда уже ждет, если пожелает Аллах.';

  @override
  String get dua_qadr_title => 'Дуа в Ляйлятуль-Кадр';

  @override
  String get dua_qadr_ar => 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي';

  @override
  String get dua_qadr_trans => 'Аллахумма иннака \'афуввун тухиббуль-\'афва фа\'фу \'анни';

  @override
  String get dua_qadr_text => 'О Аллах, поистине, Ты — Прощающий, Ты любишь прощать, так прости же меня.';

  @override
  String get dua_kursi_title => 'Аят аль-Курси';

  @override
  String get dua_kursi_ar => 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ';

  @override
  String get dua_kursi_trans => 'Аллаху ля иляха илля Хуваль-Хайюль-Кайюм. Ля та\'хузуху синатун ва ля наум...';

  @override
  String get dua_kursi_text => 'Аллах — нет божества, кроме Него, Живого, Вседержителя. Им не овладевают ни дремота, ни сон...';

  @override
  String get dua_istighfar_title => 'Сайидуль Истигфар (Господин молитв о прощении)';

  @override
  String get dua_istighfar_ar => 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ';

  @override
  String get dua_istighfar_trans => 'Аллахумма Анта Рабби ля иляха илля Анта, халяктани ва ана \'абдук...';

  @override
  String get dua_istighfar_text => 'О Аллах, Ты — мой Господь, и нет божества, кроме Тебя. Ты создал меня, и я — Твой раб...';

  @override
  String get dua_sadness_title => 'Дуа от тревоги и печали';

  @override
  String get dua_sadness_ar => 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ';

  @override
  String get dua_sadness_trans => 'Аллахумма инни а\'узу бика миналь-хамми валь-хазан';

  @override
  String get dua_sadness_text => 'О Аллах, я прибегаю к Твоей защите от тревоги и печали.';

  @override
  String get dua_morning_title => 'Дуа для защиты на день';

  @override
  String get dua_morning_ar => 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ';

  @override
  String get dua_morning_trans => 'Бисмилляхиль-лязи ля йадурру ма\'асмихи шай\'ун филь-арды ва ля фис-сама\'и ва хувас-Сами\'уль-\'Алим';

  @override
  String get dua_morning_text => 'С именем Аллаха, с именем Которого ничто не причинит вреда ни на земле, ни на небесах, ведь Он — Слышащий, Знающий.';

  @override
  String get swipeToSelect => 'Смахните для выбора';

  @override
  String get timeAdjustments => 'Корректировка времени (Ихтият)';

  @override
  String get fineTuneTimes => 'Точная настройка времени намаза';

  @override
  String get timeAdjustmentsShort => 'Корректировка времени';

  @override
  String get adjustmentDesc => 'Если время вашей мечети немного отличается, вы можете настроить минуты здесь.';

  @override
  String get aboutLegal => 'О приложении и Правовая инфо';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования (EULA)';

  @override
  String get appVersion => 'Версия приложения';
}
