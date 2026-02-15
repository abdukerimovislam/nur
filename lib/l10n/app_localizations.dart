import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ky.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tg.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('kk'),
    Locale('ky'),
    Locale('ru'),
    Locale('tr'),
    Locale('ar'),
    Locale('id'),
    Locale('tg'),
    Locale('uz')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nur'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Calculating times...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @locationDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting Location...'**
  String get locationDetecting;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationError;

  /// No description provided for @timeLeftIftar.
  ///
  /// In en, this message translates to:
  /// **'Time until Iftar'**
  String get timeLeftIftar;

  /// No description provided for @timeLeftSuhoor.
  ///
  /// In en, this message translates to:
  /// **'Time until Suhoor'**
  String get timeLeftSuhoor;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @rotatePhone.
  ///
  /// In en, this message translates to:
  /// **'Rotate your phone to calibrate'**
  String get rotatePhone;

  /// No description provided for @north.
  ///
  /// In en, this message translates to:
  /// **'N'**
  String get north;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get navQibla;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @calendarHeader.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarHeader;

  /// No description provided for @hijriDate.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get hijriDate;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @madhab.
  ///
  /// In en, this message translates to:
  /// **'Asr Calculation (Madhab)'**
  String get madhab;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @madhabHanafi.
  ///
  /// In en, this message translates to:
  /// **'Hanafi'**
  String get madhabHanafi;

  /// No description provided for @madhabStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard (Shafi, Maliki, Hanbali)'**
  String get madhabStandard;

  /// No description provided for @methodMWL.
  ///
  /// In en, this message translates to:
  /// **'Muslim World League'**
  String get methodMWL;

  /// No description provided for @methodISNA.
  ///
  /// In en, this message translates to:
  /// **'ISNA (North America)'**
  String get methodISNA;

  /// No description provided for @methodEgypt.
  ///
  /// In en, this message translates to:
  /// **'Egyptian General Authority'**
  String get methodEgypt;

  /// No description provided for @methodMakkah.
  ///
  /// In en, this message translates to:
  /// **'Umm Al-Qura (Makkah)'**
  String get methodMakkah;

  /// No description provided for @methodKarachi.
  ///
  /// In en, this message translates to:
  /// **'Karachi'**
  String get methodKarachi;

  /// No description provided for @methodTehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get methodTehran;

  /// No description provided for @methodTurkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey (Diyanet)'**
  String get methodTurkey;

  /// No description provided for @methodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get methodSingapore;

  /// No description provided for @methodOther.
  ///
  /// In en, this message translates to:
  /// **'Other / Custom'**
  String get methodOther;

  /// No description provided for @locationPermissionText.
  ///
  /// In en, this message translates to:
  /// **'Location is required for accurate prayer times.'**
  String get locationPermissionText;

  /// No description provided for @suhoor.
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get suhoor;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining'**
  String get timeRemaining;

  /// No description provided for @errorLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to get location'**
  String get errorLocation;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @untilSuhoor.
  ///
  /// In en, this message translates to:
  /// **'until Suhoor'**
  String get untilSuhoor;

  /// No description provided for @untilIftar.
  ///
  /// In en, this message translates to:
  /// **'until Iftar'**
  String get untilIftar;

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'ALIGNED'**
  String get qiblaAligned;

  /// No description provided for @calibrateCompass.
  ///
  /// In en, this message translates to:
  /// **'Calibrate by waving phone in a figure-8'**
  String get calibrateCompass;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NUR'**
  String get onboardTitle1;

  /// No description provided for @onboardDesc1.
  ///
  /// In en, this message translates to:
  /// **'Your premium companion for the Holy Month of Ramadan. Minimalist, accurate, and ad-free.'**
  String get onboardDesc1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Accurate Timings'**
  String get onboardTitle2;

  /// No description provided for @onboardDesc2.
  ///
  /// In en, this message translates to:
  /// **'To calculate the exact Suhoor and Iftar times for your specific region, we need access to your location.'**
  String get onboardDesc2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Never Miss a Moment'**
  String get onboardTitle3;

  /// No description provided for @onboardDesc3.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so we can gently remind you 5 minutes before Suhoor and Iftar.'**
  String get onboardDesc3;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @bioTitle.
  ///
  /// In en, this message translates to:
  /// **'Body State'**
  String get bioTitle;

  /// No description provided for @bioNightTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery & Hydration'**
  String get bioNightTitle;

  /// No description provided for @bioNightDesc.
  ///
  /// In en, this message translates to:
  /// **'Your body is resting. Drink plenty of water and prepare for the fast.'**
  String get bioNightDesc;

  /// No description provided for @bioPhase1Title.
  ///
  /// In en, this message translates to:
  /// **'Blood Sugar Normalizes'**
  String get bioPhase1Title;

  /// No description provided for @bioPhase1Desc.
  ///
  /// In en, this message translates to:
  /// **'Blood sugar levels drop and normalize. Insulin levels decrease.'**
  String get bioPhase1Desc;

  /// No description provided for @bioPhase2Title.
  ///
  /// In en, this message translates to:
  /// **'Digestive System Rests'**
  String get bioPhase2Title;

  /// No description provided for @bioPhase2Desc.
  ///
  /// In en, this message translates to:
  /// **'Digestion ends. The body begins to draw energy from glycogen reserves.'**
  String get bioPhase2Desc;

  /// No description provided for @bioPhase3Title.
  ///
  /// In en, this message translates to:
  /// **'Fat Burning (Ketosis)'**
  String get bioPhase3Title;

  /// No description provided for @bioPhase3Desc.
  ///
  /// In en, this message translates to:
  /// **'Glycogen is depleted. The body starts burning fat for energy.'**
  String get bioPhase3Desc;

  /// No description provided for @bioPhase4Title.
  ///
  /// In en, this message translates to:
  /// **'Autophagy Begins'**
  String get bioPhase4Title;

  /// No description provided for @bioPhase4Desc.
  ///
  /// In en, this message translates to:
  /// **'Cellular repair starts. The body clears out damaged cells and regenerates.'**
  String get bioPhase4Desc;

  /// No description provided for @fastingProgress.
  ///
  /// In en, this message translates to:
  /// **'Fasting Progress'**
  String get fastingProgress;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders 5 mins before fasting events'**
  String get enableNotificationsDesc;

  /// No description provided for @smartAlarms.
  ///
  /// In en, this message translates to:
  /// **'Smart Alarms'**
  String get smartAlarms;

  /// No description provided for @smartAlarmsDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically adjusts to daily Suhoor and Iftar times.'**
  String get smartAlarmsDesc;

  /// No description provided for @suhoorAlarm.
  ///
  /// In en, this message translates to:
  /// **'Wake up for Suhoor'**
  String get suhoorAlarm;

  /// No description provided for @iftarAlarm.
  ///
  /// In en, this message translates to:
  /// **'Prepare for Iftar'**
  String get iftarAlarm;

  /// No description provided for @alarmOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get alarmOff;

  /// No description provided for @alarm20Min.
  ///
  /// In en, this message translates to:
  /// **'20 min'**
  String get alarm20Min;

  /// No description provided for @alarm30Min.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get alarm30Min;

  /// No description provided for @alarm60Min.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get alarm60Min;

  /// No description provided for @tapForDua.
  ///
  /// In en, this message translates to:
  /// **'Tap for Dua'**
  String get tapForDua;

  /// No description provided for @duaSuhoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Dua for Suhoor (Fasting Intention)'**
  String get duaSuhoorTitle;

  /// No description provided for @duaSuhoorArabic.
  ///
  /// In en, this message translates to:
  /// **'نَوَيْتُ أَنْ أَصُومَ صَوْمَ شَهْرِ رَمَضَانَ مِنَ الْفَجْرِ إِلَى الْمَغْرِبِ خَالِصًا لِلَّهِ تَعَالَى'**
  String get duaSuhoorArabic;

  /// No description provided for @duaSuhoorTranslit.
  ///
  /// In en, this message translates to:
  /// **'Nawaytu an asuma sawma shahri ramadana minal fajri ilal maghribi khalisan lillahi ta\'ala.'**
  String get duaSuhoorTranslit;

  /// No description provided for @duaSuhoorTransl.
  ///
  /// In en, this message translates to:
  /// **'I intend to keep the fast for the month of Ramadan from dawn till dusk sincerely for Allah.'**
  String get duaSuhoorTransl;

  /// No description provided for @duaIftarTitle.
  ///
  /// In en, this message translates to:
  /// **'Dua for Iftar (Breaking Fast)'**
  String get duaIftarTitle;

  /// No description provided for @duaIftarArabic.
  ///
  /// In en, this message translates to:
  /// **'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ'**
  String get duaIftarArabic;

  /// No description provided for @duaIftarTranslit.
  ///
  /// In en, this message translates to:
  /// **'Allahumma inni laka sumtu wa bika aamantu wa \'alayka tawakkaltu wa \'ala rizqika aftartu.'**
  String get duaIftarTranslit;

  /// No description provided for @duaIftarTransl.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance.'**
  String get duaIftarTransl;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @tasbihTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get tasbihTitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subhanAllah.
  ///
  /// In en, this message translates to:
  /// **'Subhan Allah'**
  String get subhanAllah;

  /// No description provided for @alhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get alhamdulillah;

  /// No description provided for @allahuAkbar.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get allahuAkbar;

  /// No description provided for @astaghfirullah.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get astaghfirullah;

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the counter?'**
  String get resetConfirm;

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetAction;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NUR'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'RAMADAN COMPANION'**
  String get appSubtitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @qiblaSearching.
  ///
  /// In en, this message translates to:
  /// **'SEARCHING'**
  String get qiblaSearching;

  /// No description provided for @holyKaaba.
  ///
  /// In en, this message translates to:
  /// **'HOLY KAABA'**
  String get holyKaaba;

  /// No description provided for @fastingStatus.
  ///
  /// In en, this message translates to:
  /// **'Fasting Status'**
  String get fastingStatus;

  /// No description provided for @statusFasted.
  ///
  /// In en, this message translates to:
  /// **'Fasted'**
  String get statusFasted;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed (Qaza)'**
  String get statusMissed;

  /// No description provided for @statusNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get statusNotSet;

  /// No description provided for @shareProgress.
  ///
  /// In en, this message translates to:
  /// **'My Ramadan Fasting Progress 🌙\nFasted: {fasted} days\nMissed (Qaza): {missed} days\nTracked with NUR app!'**
  String shareProgress(int fasted, int missed);

  /// No description provided for @shareImageTitle.
  ///
  /// In en, this message translates to:
  /// **'My Ramadan Fasting'**
  String get shareImageTitle;

  /// No description provided for @shareImageDays.
  ///
  /// In en, this message translates to:
  /// **'Days Fasted'**
  String get shareImageDays;

  /// No description provided for @shareImageApp.
  ///
  /// In en, this message translates to:
  /// **'NUR: Muslim Assistant'**
  String get shareImageApp;

  /// No description provided for @futureDateError.
  ///
  /// In en, this message translates to:
  /// **'Cannot mark future days'**
  String get futureDateError;

  /// No description provided for @dailyInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily Inspiration'**
  String get dailyInspiration;

  /// No description provided for @quote1_ar.
  ///
  /// In en, this message translates to:
  /// **'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِن قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ'**
  String get quote1_ar;

  /// No description provided for @quote1_text.
  ///
  /// In en, this message translates to:
  /// **'O you who have believed, decreed upon you is fasting as it was decreed upon those before you that you may become righteous.'**
  String get quote1_text;

  /// No description provided for @quote1_source.
  ///
  /// In en, this message translates to:
  /// **'Quran, Al-Baqarah (2:183)'**
  String get quote1_source;

  /// No description provided for @quote2_ar.
  ///
  /// In en, this message translates to:
  /// **'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ'**
  String get quote2_ar;

  /// No description provided for @quote2_text.
  ///
  /// In en, this message translates to:
  /// **'Whoever observes fasts during the month of Ramadan out of sincere faith, and hoping to attain Allah\'s rewards, then all his past sins will be forgiven.'**
  String get quote2_text;

  /// No description provided for @quote2_source.
  ///
  /// In en, this message translates to:
  /// **'Sahih al-Bukhari (38)'**
  String get quote2_source;

  /// No description provided for @quote3_ar.
  ///
  /// In en, this message translates to:
  /// **'لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ'**
  String get quote3_ar;

  /// No description provided for @quote3_text.
  ///
  /// In en, this message translates to:
  /// **'The Night of Decree is better than a thousand months.'**
  String get quote3_text;

  /// No description provided for @quote3_source.
  ///
  /// In en, this message translates to:
  /// **'Quran, Al-Qadr (97:3)'**
  String get quote3_source;

  /// No description provided for @duaLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dua Library'**
  String get duaLibraryTitle;

  /// No description provided for @categoryRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get categoryRamadan;

  /// No description provided for @categoryMorningEvening.
  ///
  /// In en, this message translates to:
  /// **'Morning & Evening'**
  String get categoryMorningEvening;

  /// No description provided for @categoryAfterSalah.
  ///
  /// In en, this message translates to:
  /// **'After Salah'**
  String get categoryAfterSalah;

  /// No description provided for @categoryProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get categoryProtection;

  /// No description provided for @categoryForgiveness.
  ///
  /// In en, this message translates to:
  /// **'Forgiveness'**
  String get categoryForgiveness;

  /// No description provided for @categoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family & Children'**
  String get categoryFamily;

  /// No description provided for @transcription.
  ///
  /// In en, this message translates to:
  /// **'Transcription'**
  String get transcription;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copied;

  /// No description provided for @duaSuhoorTrans.
  ///
  /// In en, this message translates to:
  /// **'Nawaitu an asuma sawma shahri ramadana minal fajri ilal maghribi khalisan lillahi ta\'ala'**
  String get duaSuhoorTrans;

  /// No description provided for @duaSuhoorTranslate.
  ///
  /// In en, this message translates to:
  /// **'I intend to keep the fast for tomorrow in the month of Ramadan, sincerely for Allah.'**
  String get duaSuhoorTranslate;

  /// No description provided for @duaIftarTrans.
  ///
  /// In en, this message translates to:
  /// **'Dhahabadh-dhama\'u wabtallatil-\'urooqu wa thabatal-ajru in sha\'Allah'**
  String get duaIftarTrans;

  /// No description provided for @duaIftarTranslate.
  ///
  /// In en, this message translates to:
  /// **'The thirst has gone, the veins are quenched, and the reward is confirmed, if Allah wills.'**
  String get duaIftarTranslate;

  /// No description provided for @dua_qadr_title.
  ///
  /// In en, this message translates to:
  /// **'Dua for Laylat al-Qadr'**
  String get dua_qadr_title;

  /// No description provided for @dua_qadr_ar.
  ///
  /// In en, this message translates to:
  /// **'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي'**
  String get dua_qadr_ar;

  /// No description provided for @dua_qadr_trans.
  ///
  /// In en, this message translates to:
  /// **'Allahumma innaka \'afuwwun tuhibbul-\'afwa fa\'fu \'anni'**
  String get dua_qadr_trans;

  /// No description provided for @dua_qadr_text.
  ///
  /// In en, this message translates to:
  /// **'O Allah, You are Forgiving and love forgiveness, so forgive me.'**
  String get dua_qadr_text;

  /// No description provided for @dua_kursi_title.
  ///
  /// In en, this message translates to:
  /// **'Ayat al-Kursi'**
  String get dua_kursi_title;

  /// No description provided for @dua_kursi_ar.
  ///
  /// In en, this message translates to:
  /// **'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ'**
  String get dua_kursi_ar;

  /// No description provided for @dua_kursi_trans.
  ///
  /// In en, this message translates to:
  /// **'Allahu la ilaha illa Huwal-Hayyul-Qayyum. La ta\'khudhuhu sinatun wa la nawm...'**
  String get dua_kursi_trans;

  /// No description provided for @dua_kursi_text.
  ///
  /// In en, this message translates to:
  /// **'Allah! There is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep...'**
  String get dua_kursi_text;

  /// No description provided for @dua_istighfar_title.
  ///
  /// In en, this message translates to:
  /// **'Sayyidul Istighfar'**
  String get dua_istighfar_title;

  /// No description provided for @dua_istighfar_ar.
  ///
  /// In en, this message translates to:
  /// **'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ'**
  String get dua_istighfar_ar;

  /// No description provided for @dua_istighfar_trans.
  ///
  /// In en, this message translates to:
  /// **'Allahumma Anta Rabbi la ilaha illa Anta, khalaqtani wa ana \'abduka...'**
  String get dua_istighfar_trans;

  /// No description provided for @dua_istighfar_text.
  ///
  /// In en, this message translates to:
  /// **'O Allah, You are my Lord, there is no deity except You. You created me and I am Your servant...'**
  String get dua_istighfar_text;

  /// No description provided for @dua_sadness_title.
  ///
  /// In en, this message translates to:
  /// **'Dua for Anxiety and Sorrow'**
  String get dua_sadness_title;

  /// No description provided for @dua_sadness_ar.
  ///
  /// In en, this message translates to:
  /// **'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ'**
  String get dua_sadness_ar;

  /// No description provided for @dua_sadness_trans.
  ///
  /// In en, this message translates to:
  /// **'Allahumma inni a\'udhu bika minal-hammi wal-hazan'**
  String get dua_sadness_trans;

  /// No description provided for @dua_sadness_text.
  ///
  /// In en, this message translates to:
  /// **'O Allah, I seek refuge in You from anxiety and sorrow.'**
  String get dua_sadness_text;

  /// No description provided for @dua_morning_title.
  ///
  /// In en, this message translates to:
  /// **'Protection for the Day'**
  String get dua_morning_title;

  /// No description provided for @dua_morning_ar.
  ///
  /// In en, this message translates to:
  /// **'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ'**
  String get dua_morning_ar;

  /// No description provided for @dua_morning_trans.
  ///
  /// In en, this message translates to:
  /// **'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-Sami\'ul-\'Alim'**
  String get dua_morning_trans;

  /// No description provided for @dua_morning_text.
  ///
  /// In en, this message translates to:
  /// **'In the name of Allah, with Whose name nothing can cause harm in the earth nor in the heavens, and He is the All-Hearing, the All-Knowing.'**
  String get dua_morning_text;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr', 'kk', 'ky', 'ru', 'tr', 'ar', 'id', 'tg', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
    case 'kk': return AppLocalizationsKk();
    case 'ky': return AppLocalizationsKy();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
    case 'ar': return AppLocalizationsAr();
    case 'id': return AppLocalizationsId();
    case 'tg': return AppLocalizationsTg();
    case 'uz': return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
