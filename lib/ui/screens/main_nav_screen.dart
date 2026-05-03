import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upgrader/upgrader.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/notification_service.dart';

import 'qibla_screen.dart';
import 'quran_ai_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';
import 'widgets_hub_screen.dart';

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
    if (payload == null) return;
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
    final List<Widget> screens = [
      const TodayScreen(key: PageStorageKey('today')),
      const QuranAIScreen(key: PageStorageKey('quran_ai')),
      QiblaScreen(
        key: const PageStorageKey('qibla'),
        isActive: _selectedIndex == 2,
        onMoveBack: () => _onDestinationSelected(0),
      ),
      const WidgetsHubScreen(key: PageStorageKey('widgets')),
      const SettingsScreen(key: PageStorageKey('settings')),
    ];

    return UpgradeAlert(
      dialogStyle: Platform.isIOS
          ? UpgradeDialogStyle.cupertino
          : UpgradeDialogStyle.material,
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.94),
            border: const Border(
              top: BorderSide(color: AppColors.border),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  );
                }

                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                );
              }),
            ),
            child: NavigationBar(
              height: 74,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.primary.withOpacity(0.14),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.today_outlined, color: AppColors.textMuted),
                  selectedIcon: Icon(
                    Icons.today_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'Today',
                ),
                NavigationDestination(
                  icon: Icon(Icons.graphic_eq_outlined,
                      color: AppColors.textMuted),
                  selectedIcon: Icon(
                    Icons.graphic_eq_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'Quran AI',
                ),
                NavigationDestination(
                  icon:
                      Icon(Icons.explore_outlined, color: AppColors.textMuted),
                  selectedIcon: Icon(
                    Icons.explore,
                    color: AppColors.primary,
                  ),
                  label: 'Qibla',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.auto_awesome_outlined,
                    color: AppColors.textMuted,
                  ),
                  selectedIcon: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                  ),
                  label: 'Inspire',
                ),
                NavigationDestination(
                  icon:
                      Icon(Icons.settings_outlined, color: AppColors.textMuted),
                  selectedIcon: Icon(
                    Icons.settings,
                    color: AppColors.primary,
                  ),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
