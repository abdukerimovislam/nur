import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upgrader/upgrader.dart';

import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/notification_service.dart';
import '../widgets/dua_bottom_sheet.dart';

import 'home_screen.dart';
import 'qibla_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'tasbih_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  StreamSubscription? _notificationSubscription;
  static bool _hasProcessedLaunchIntent = false;

  @override
  void initState() {
    super.initState();
    _initNotificationListener();
    // ИСПРАВЛЕНИЕ DEADLOCK'а: Вызов NotificationService().requestPermissions()
    // удален отсюда, так как он конфликтовал с запросом геолокации при запуске.
  }

  void _initNotificationListener() async {
    _notificationSubscription = NotificationService()
        .selectNotificationStream
        .stream
        .listen(_onNotificationTapped);

    if (!_hasProcessedLaunchIntent) {
      final details = await NotificationService().getLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        final payload = details.notificationResponse?.payload;
        if (payload != null) {
          _onNotificationTapped(payload);
        }
      }
      _hasProcessedLaunchIntent = true;
    }
  }

  void _onNotificationTapped(String? payload) {
    if (payload == 'action_dua_suhoor' || payload == 'action_dua_iftar') {
      final isSuhoor = payload == 'action_dua_suhoor';
      if (_selectedIndex != 0) {
        setState(() => _selectedIndex = 0);
      }
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          DuaBottomSheet.show(context, isSuhoor: isSuhoor);
        }
      });
    }
  }

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> screens = [
      const HomeScreen(key: PageStorageKey('home')),
      const TasbihScreen(key: PageStorageKey('tasbih')),
      QiblaScreen(
        key: const PageStorageKey('qibla'),
        isActive: _selectedIndex == 2,
        onMoveBack: () => _onDestinationSelected(0),
      ),
      const CalendarScreen(key: PageStorageKey('calendar')),
      const SettingsScreen(key: PageStorageKey('settings')),
    ];

    return UpgradeAlert(
      dialogStyle: Platform.isIOS ? UpgradeDialogStyle.cupertino : UpgradeDialogStyle.material,
      upgrader: Upgrader(
        durationUntilAlertAgain: const Duration(days: 1),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: List.generate(screens.length, (index) {
            final bool active = index == _selectedIndex;
            return IgnorePointer(
              ignoring: !active,
              child: FocusScope(
                canRequestFocus: active,
                child: ExcludeSemantics(
                  excluding: !active,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    opacity: active ? 1.0 : 0.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      scale: active ? 1.0 : 0.95,
                      child: KeyedSubtree(
                        key: ValueKey('screen_wrapper_$index'),
                        child: screens[index],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary);
              }
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70);
            }),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.surface,
            elevation: 10,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined, color: Colors.white70),
                selectedIcon: const Icon(Icons.home, color: AppColors.primary),
                label: l10n.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.fingerprint_outlined, color: Colors.white70),
                selectedIcon: const Icon(Icons.fingerprint, color: AppColors.primary),
                label: l10n.tasbihTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined, color: Colors.white70),
                selectedIcon: const Icon(Icons.explore, color: AppColors.primary),
                label: l10n.navQibla,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined, color: Colors.white70),
                selectedIcon: const Icon(Icons.calendar_month, color: AppColors.primary),
                label: l10n.navCalendar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                selectedIcon: const Icon(Icons.settings, color: AppColors.primary),
                label: l10n.settingsTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}