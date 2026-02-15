import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для SystemChrome
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Пакеты сервисов
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart'; // <--- ДЛЯ IOS

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'core/constants/app_colors.dart';
import 'providers/prayer_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/tracker_provider.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  // 1. Инициализация привязок
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Удержание нативного сплэша
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. Настройка системного UI (Статус-бар и навигация)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Фиксируем ориентацию (важно для сохранения верстки)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 4. Инициализация Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  // 5. Инициализация рекламного движка и ATT
  unawaited(MobileAds.instance.initialize());
  if (Platform.isIOS) {
    // Запрос на отслеживание для Apple (без этого — отказ в сторе)
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  // 6. Инициализация локальных сервисов
  await StorageService().init();
  await NotificationService().init();

  runApp(const RamadanApp());

  // 7. Удаление нативного сплэша
  FlutterNativeSplash.remove();
}

class RamadanApp extends StatelessWidget {
  const RamadanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
        ChangeNotifierProvider(create: (_) => TrackerProvider()),
      ],
      child: Selector<PrayerProvider, Locale>(
        selector: (context, provider) => provider.locale,
        builder: (context, currentLocale, child) {
          return MaterialApp(
            locale: currentLocale,
            onGenerateTitle: (context) =>
            AppLocalizations.of(context)?.appTitle ?? 'NUR: Ramadan',
            debugShowCheckedModeBanner: false,

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), Locale('ru', ''),
              Locale('ar', ''), Locale('tr', ''),
              Locale('id', ''), Locale('fr', ''),
              Locale('ky', ''), Locale('kk', ''),
              Locale('uz', ''), Locale('tg', ''),
            ],

            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.background,
              primaryColor: AppColors.primary,
              splashColor: AppColors.primary.withOpacity(0.1),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
              ),
              useMaterial3: true,
              // Улучшаем шрифты для арабского региона
              fontFamily: Platform.isIOS ? 'SF Pro Display' : 'Roboto',
            ),

            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}