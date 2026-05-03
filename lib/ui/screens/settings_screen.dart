import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import 'nur_premium_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<PrayerProvider>();

    final currentLangCode =
        context.select<PrayerProvider, String>((p) => p.locale.languageCode);
    final currentMadhab =
        context.select<PrayerProvider, Madhab>((p) => p.madhab);
    final currentMethod =
        context.select<PrayerProvider, CalculationMethod>((p) => p.method);
    final isManualLocation =
        context.select<PrayerProvider, bool>((p) => p.isManualLocation);
    final currentCity = context.select<PrayerProvider, String>((p) => p.city);
    final isLoading = context.select<PrayerProvider, bool>((p) => p.isLoading);
    final notificationsEnabled =
        context.select<PrayerProvider, bool>((p) => p.notificationsEnabled);
    final tahajjudAlarmOffset =
        context.select<PrayerProvider, int>((p) => p.tahajjudAlarmOffset);
    final hijriAdjustment =
        context.select<PrayerProvider, int>((p) => p.hijriAdjustment);

    final currentLangName = _supportedLanguages.firstWhere(
      (lang) => lang['code'] == currentLangCode,
      orElse: () => {'name': 'English'},
    )['name']!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _buildPremiumCard(context),
          _buildSectionHeader(l10n.generalSection),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingsTile(
                  context,
                  title: l10n.language,
                  value: currentLangName,
                  icon: Icons.language,
                  onTap: () => _showLanguagePicker(context, provider, l10n),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSettingsTile(
                  context,
                  title: l10n.madhab,
                  value: _getMadhabName(currentMadhab, l10n),
                  icon: Icons.people_outline,
                  onTap: () => _showMadhabPicker(context, provider, l10n),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSettingsTile(
                  context,
                  title: l10n.calculationMethod,
                  value: _getMethodName(currentMethod, l10n),
                  icon: Icons.calculate_outlined,
                  onTap: () => _showMethodPicker(context, provider, l10n),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSettingsTile(
                  context,
                  title: l10n.location,
                  value: isLoading ? '...' : currentCity,
                  icon: isManualLocation
                      ? Icons.location_city
                      : Icons.location_on_outlined,
                  onTap: () =>
                      _showLocationSearchSheet(context, provider, l10n),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSettingsTile(
                  context,
                  title: l10n.timeAdjustments,
                  value: l10n.fineTuneTimes,
                  icon: Icons.tune,
                  onTap: () => _showAdjustmentPicker(context, provider, l10n),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSettingsTile(
                  context,
                  title: currentLangCode == 'ru'
                      ? 'Корректировка Хиджры'
                      : 'Hijri Adjustment',
                  value: hijriAdjustment == 0
                      ? (currentLangCode == 'ru'
                          ? 'Автоматически'
                          : 'Automatic')
                      : (hijriAdjustment > 0
                          ? '+$hijriAdjustment'
                          : '$hijriAdjustment'),
                  icon: Icons.calendar_month,
                  onTap: () => _showHijriAdjustmentPicker(
                    context,
                    provider,
                    currentLangCode,
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                SwitchListTile(
                  activeColor: AppColors.primary,
                  inactiveTrackColor: Colors.white12,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    l10n.enableNotifications,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    l10n.enableNotificationsDesc,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  value: notificationsEnabled,
                  onChanged: (bool value) async {
                    provider.toggleNotifications(value);
                    if (value) {
                      await NotificationService().requestPermissions();
                    }
                  },
                ),
                if (notificationsEnabled) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 16, bottom: 8),
                    child: Text(
                      'Prayer reminders'.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildAlarmRow(
                    title: l10n.tahajjudAlarm,
                    icon: Icons.star_border_purple500_outlined,
                    value: tahajjudAlarmOffset,
                    onChanged: (val) {
                      if (val != null) provider.updateTahajjudAlarm(val);
                    },
                    l10n: l10n,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          _buildSectionHeader('Support'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildSimpleTile(
                  title: 'Support Nur',
                  value: 'Donate',
                  icon: Icons.volunteer_activism_outlined,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Donations will be connected later.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSimpleTile(
                  title: 'Share Nur',
                  icon: Icons.ios_share_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature will be connected later.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildSectionHeader(l10n.aboutLegal),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildSimpleTile(
                  title: l10n.privacyPolicy,
                  icon: Icons.privacy_tip_outlined,
                  onTap: () =>
                      _launchURL('https://sites.google.com/view/nur-app'),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSimpleTile(
                  title: l10n.termsOfUse,
                  icon: Icons.gavel_outlined,
                  onTap: () => _launchURL(
                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                  ),
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSimpleTile(
                  title: l10n.appVersion,
                  value: '1.0.0 (Build 13)',
                  icon: Icons.info_outline,
                  onTap: () {},
                  showChevron: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.32)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        title: const Text(
          'Nur Premium',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        subtitle: const Text(
          'Quran AI, widgets and prayer analytics',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NurPremiumScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlarmRow({
    required String title,
    required IconData icon,
    required int value,
    required ValueChanged<int?> onChanged,
    required AppLocalizations l10n,
  }) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Icon(icon, color: Colors.white54, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: _buildDropdown(
        currentValue: value,
        onChanged: onChanged,
        l10n: l10n,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.textMuted,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSimpleTile({
    required String title,
    String? value,
    required IconData icon,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          if (showChevron) const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDropdown({
    required int currentValue,
    required void Function(int?) onChanged,
    required AppLocalizations l10n,
  }) {
    return DropdownButton<int>(
      value: currentValue,
      dropdownColor: AppColors.surface,
      underline: const SizedBox(),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      items: [
        DropdownMenuItem(value: 0, child: Text(l10n.alarmOff)),
        DropdownMenuItem(value: 20, child: Text(l10n.alarm20Min)),
        DropdownMenuItem(value: 30, child: Text(l10n.alarm30Min)),
        DropdownMenuItem(value: 60, child: Text(l10n.alarm60Min)),
      ],
      onChanged: onChanged,
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  void _showLocationSearchSheet(
    BuildContext context,
    PrayerProvider provider,
    AppLocalizations l10n,
  ) {
    final TextEditingController cityController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.changeLocation,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: cityController,
                style: const TextStyle(color: AppColors.textPrimary),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.enterCityHint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    provider.setManualLocation(value.trim());
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (cityController.text.trim().isNotEmpty) {
                      provider.setManualLocation(cityController.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    l10n.searchBtn,
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (provider.isManualLocation || provider.error != null)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      provider.enableAutoLocation();
                      Navigator.pop(ctx);
                    },
                    icon:
                        const Icon(Icons.my_location, color: AppColors.primary),
                    label: Text(
                      l10n.useAutoLocation,
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _showHijriAdjustmentPicker(
    BuildContext context,
    PrayerProvider provider,
    String langCode,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  langCode == 'ru'
                      ? 'Сдвиг даты (Хиджра)'
                      : 'Hijri Date Offset',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...[-2, -1, 0, 1, 2].map((day) {
                final isSelected = provider.hijriAdjustment == day;
                String label;
                if (day == 0) {
                  label = langCode == 'ru' ? '0 дней (Авто)' : '0 days (Auto)';
                } else if (day > 0) {
                  label = '+$day ${langCode == 'ru' ? 'день/дней' : 'days'}';
                } else {
                  label = '$day ${langCode == 'ru' ? 'день/дней' : 'days'}';
                }

                return ListTile(
                  title: Text(
                    label,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    provider.updateHijriAdjustment(day);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAdjustmentPicker(
    BuildContext context,
    PrayerProvider provider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final storage = provider.getStorageService();
            int fajrAdj = storage.getAdjustment('fajr');
            int sunriseAdj = storage.getAdjustment('sunrise');
            int dhuhrAdj = storage.getAdjustment('dhuhr');
            int asrAdj = storage.getAdjustment('asr');
            int maghribAdj = storage.getAdjustment('maghrib');
            int ishaAdj = storage.getAdjustment('isha');

            Widget buildStepper(
              String name,
              int currentValue,
              Function(int) onChanged,
            ) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if (currentValue > -10) {
                              onChanged(currentValue - 1);
                            }
                          },
                        ),
                        SizedBox(
                          width: 30,
                          child: Text(
                            currentValue > 0
                                ? '+$currentValue'
                                : '$currentValue',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if (currentValue < 10) {
                              onChanged(currentValue + 1);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            }

            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            l10n.timeAdjustmentsShort,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.adjustmentDesc,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    Expanded(
                      child: ListView(
                        children: [
                          buildStepper(l10n.fajr, fajrAdj, (val) {
                            setState(() => fajrAdj = val);
                            provider.updateManualAdjustment('fajr', val);
                          }),
                          buildStepper(l10n.sunrise, sunriseAdj, (val) {
                            setState(() => sunriseAdj = val);
                            provider.updateManualAdjustment('sunrise', val);
                          }),
                          buildStepper(l10n.dhuhr, dhuhrAdj, (val) {
                            setState(() => dhuhrAdj = val);
                            provider.updateManualAdjustment('dhuhr', val);
                          }),
                          buildStepper(l10n.asr, asrAdj, (val) {
                            setState(() => asrAdj = val);
                            provider.updateManualAdjustment('asr', val);
                          }),
                          buildStepper(l10n.maghrib, maghribAdj, (val) {
                            setState(() => maghribAdj = val);
                            provider.updateManualAdjustment('maghrib', val);
                          }),
                          buildStepper(l10n.isha, ishaAdj, (val) {
                            setState(() => ishaAdj = val);
                            provider.updateManualAdjustment('isha', val);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    PrayerProvider provider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.language,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = _supportedLanguages[index];
                      final isSelected =
                          provider.locale.languageCode == lang['code'];

                      return ListTile(
                        title: Text(
                          lang['name']!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          provider.changeLanguage(lang['code']!);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMadhabPicker(
    BuildContext context,
    PrayerProvider provider,
    AppLocalizations l10n,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.madhab,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  l10n.madhabHanafi,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                trailing: provider.madhab == Madhab.hanafi
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.updateMadhab(Madhab.hanafi);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(
                  l10n.madhabStandard,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Shafi, Maliki, Hanbali',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                trailing: provider.madhab == Madhab.shafi
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.updateMadhab(Madhab.shafi);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMethodPicker(
    BuildContext context,
    PrayerProvider provider,
    AppLocalizations l10n,
  ) {
    final methods = [
      CalculationMethod.muslim_world_league,
      CalculationMethod.north_america,
      CalculationMethod.egyptian,
      CalculationMethod.umm_al_qura,
      CalculationMethod.turkey,
      CalculationMethod.karachi,
      CalculationMethod.tehran,
      CalculationMethod.singapore,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.calculationMethod,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: methods.length,
                    itemBuilder: (ctx, index) {
                      final method = methods[index];
                      final isSelected = provider.method == method;

                      return ListTile(
                        title: Text(
                          _getMethodName(method, l10n),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          provider.updateCalculationMethod(method);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getMadhabName(Madhab madhab, AppLocalizations l10n) {
    if (madhab == Madhab.hanafi) return l10n.madhabHanafi;
    return l10n.madhabStandard;
  }

  String _getMethodName(CalculationMethod method, AppLocalizations l10n) {
    switch (method) {
      case CalculationMethod.muslim_world_league:
        return l10n.methodMWL;
      case CalculationMethod.north_america:
        return l10n.methodISNA;
      case CalculationMethod.egyptian:
        return l10n.methodEgypt;
      case CalculationMethod.umm_al_qura:
        return l10n.methodMakkah;
      case CalculationMethod.karachi:
        return l10n.methodKarachi;
      case CalculationMethod.turkey:
        return l10n.methodTurkey;
      case CalculationMethod.singapore:
        return l10n.methodSingapore;
      case CalculationMethod.tehran:
        return l10n.methodTehran;
      default:
        return l10n.methodOther;
    }
  }
}
