import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'data/services/nur_widget_service.dart';
import 'core/constants/app_colors.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/prayer_provider.dart';
import 'providers/prayer_tracker_provider.dart';
import 'providers/quran_ai_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/tracker_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

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
    debugPrint('Firebase init failed: $e');
  }

  if (Platform.isIOS) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  unawaited(MobileAds.instance.initialize());

  await StorageService().init();
  await NotificationService().init();
  await NurWidgetService.init();

  runApp(const NurApp());

  FlutterNativeSplash.remove();
}

class NurApp extends StatelessWidget {
  const NurApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PrayerProvider>(
          create: (_) => PrayerProvider(),
        ),
        ChangeNotifierProvider<PrayerTrackerProvider>(
          create: (_) => PrayerTrackerProvider(),
        ),
        ChangeNotifierProvider<QuranAIProvider>(
          create: (_) => QuranAIProvider(),
        ),
        ChangeNotifierProvider<TasbihProvider>(
          create: (_) => TasbihProvider(),
        ),
        ChangeNotifierProvider<TrackerProvider>(
          create: (_) => TrackerProvider(),
        ),
      ],
      child: Selector<PrayerProvider, Locale>(
        selector: (context, provider) => provider.locale,
        builder: (context, currentLocale, child) {
          return MaterialApp(
            locale: currentLocale,
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ?? 'Nur Islam Hub',
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              final mediaQueryData = MediaQuery.of(context);

              final constrainedTextScaler = mediaQueryData.textScaler.clamp(
                minScaleFactor: 1.0,
                maxScaleFactor: 1.15,
              );

              return MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: constrainedTextScaler,
                ),
                child: widget!,
              );
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
              Locale('ar', ''),
              Locale('tr', ''),
              Locale('id', ''),
              Locale('fr', ''),
              Locale('ky', ''),
              Locale('kk', ''),
              Locale('uz', ''),
              Locale('tg', ''),
            ],
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.background,
              primaryColor: AppColors.primary,
              splashColor: AppColors.primary.withOpacity(0.10),
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primary,
                secondary: AppColors.secondary,
                surface: AppColors.surface,
                error: AppColors.error,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                foregroundColor: AppColors.textPrimary,
              ),
              cardTheme: CardThemeData(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: AppColors.surface,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: AppColors.textSecondary,
                type: BottomNavigationBarType.fixed,
              ),
              useMaterial3: true,
              fontFamily: Platform.isIOS ? 'SF Pro Display' : 'Roboto',
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
