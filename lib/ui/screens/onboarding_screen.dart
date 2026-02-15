import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/preferences_service.dart';
import '../../data/services/notification_service.dart';
import '../../providers/prayer_provider.dart';
import 'main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Список всех 10 языков
  static const List<Map<String, String>> _supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ky', 'name': 'Кыргызча'},
    {'code': 'kk', 'name': 'Қазақша'},
    {'code': 'uz', 'name': 'Oʻzbekcha'},
    {'code': 'tg', 'name': 'Тоҷикӣ'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // 1. Запрашиваем локацию
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 2. Запрашиваем уведомления
      await NotificationService().requestPermissions();

      // 3. Сохраняем флаг, что обучение пройдено
      await PreferencesService().setFirstLaunchCompleted();

      // Планируем уведомления на выбранном языке
      if (mounted) {
        context.read<PrayerProvider>().scheduleNotifications();
      }

      // 4. Переходим на главный экран
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavScreen()),
        );
      }
    } catch (e) {
      debugPrint("Onboarding Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<PrayerProvider>();

    // У нас теперь 4 слайда
    const int totalSlides = 4;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: totalSlides,
                itemBuilder: (context, index) {
                  // Слайд 0: Выбор Языка
                  if (index == 0) {
                    return _buildLanguageSlide(context, l10n, provider);
                  }
                  // Слайд 1: Добро пожаловать
                  if (index == 1) {
                    return _buildStandardSlide(
                      icon: Icons.star_border_rounded,
                      title: l10n.onboardTitle1,
                      desc: l10n.onboardDesc1,
                    );
                  }
                  // Слайд 2: Локация
                  if (index == 2) {
                    return _buildStandardSlide(
                      icon: Icons.location_on_outlined,
                      title: l10n.onboardTitle2,
                      desc: l10n.onboardDesc2,
                    );
                  }
                  // Слайд 3: Умные будильники
                  if (index == 3) {
                    return _buildInteractiveAlarmSlide(context, l10n, provider);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // --- ИНДИКАТОРЫ И КНОПКИ ---
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      totalSlides,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading
                          ? null
                          : (_currentPage == totalSlides - 1
                          ? _completeOnboarding
                          : _nextPage),
                      child: _isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        _currentPage == totalSlides - 1
                            ? l10n.getStarted
                            : l10n.next,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- СЛАЙД 0: ВЫБОР ЯЗЫКА ---
  Widget _buildLanguageSlide(BuildContext context, AppLocalizations l10n, PrayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.language, size: 80, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            l10n.language, // "Язык" / "Language"
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _supportedLanguages.length,
              itemBuilder: (context, index) {
                final lang = _supportedLanguages[index];
                // Провайдер уже выбрал язык системы по умолчанию в init()
                final isSelected = provider.locale.languageCode == lang['code'];

                return GestureDetector(
                  onTap: () => provider.changeLanguage(lang['code']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang['name']!,
                          style: TextStyle(
                            fontSize: 18,
                            color: isSelected ? AppColors.primary : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- СТАНДАРТНЫЕ СЛАЙДЫ (1 и 2) ---
  Widget _buildStandardSlide({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: AppColors.primary),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- СЛАЙД 3: ИНТЕРАКТИВНЫЕ БУДИЛЬНИКИ ---
  Widget _buildInteractiveAlarmSlide(BuildContext context, AppLocalizations l10n, PrayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alarm_on_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(
            l10n.smartAlarms,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.smartAlarmsDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 40),

          _buildAlarmSelector(
            title: l10n.suhoorAlarm,
            currentValue: provider.suhoorAlarmOffset,
            onChanged: (val) => provider.updateSuhoorAlarm(val),
            l10n: l10n,
          ),
          const SizedBox(height: 20),

          _buildAlarmSelector(
            title: l10n.iftarAlarm,
            currentValue: provider.iftarAlarmOffset,
            onChanged: (val) => provider.updateIftarAlarm(val),
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmSelector({
    required String title,
    required int currentValue,
    required Function(int) onChanged,
    required AppLocalizations l10n,
  }) {
    final options = [
      {'val': 0, 'label': l10n.alarmOff},
      {'val': 20, 'label': '20m'},
      {'val': 30, 'label': '30m'},
      {'val': 60, 'label': '1h'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: options.map((opt) {
              final int optionValue = opt['val'] as int;
              final isSelected = currentValue == optionValue;

              return GestureDetector(
                onTap: () => onChanged(optionValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.white24),
                  ),
                  child: Text(
                    opt['label'] as String,
                    style: TextStyle(
                      color: isSelected ? AppColors.background : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}