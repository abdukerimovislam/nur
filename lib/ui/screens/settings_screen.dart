import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Для ссылок Privacy/EULA
import '../../l10n/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/notification_service.dart';

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
    final provider = Provider.of<PrayerProvider>(context);

    final currentLangCode = provider.locale.languageCode;
    final currentLangName = _supportedLanguages.firstWhere(
            (lang) => lang['code'] == currentLangCode,
        orElse: () => {'name': 'English'}
    )['name']!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.generalSection ?? "General"),

          // --- ОСНОВНАЯ КАРТОЧКА НАСТРОЕК ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. Выбор языка
                _buildSettingsTile(
                  context,
                  title: l10n.language,
                  value: currentLangName,
                  icon: Icons.language,
                  onTap: () => _showLanguagePicker(context, provider, l10n),
                ),

                const Divider(height: 1, indent: 56, endIndent: 16),

                // 1. Настройка Мазхаба
                _buildSettingsTile(
                  context,
                  title: l10n.madhab,
                  value: _getMadhabName(provider.madhab, l10n),
                  icon: Icons.people_outline,
                  onTap: () => _showMadhabPicker(context, provider, l10n),
                ),

                const Divider(height: 1, indent: 56, endIndent: 16),

                // 2. Настройка Метода расчета
                _buildSettingsTile(
                  context,
                  title: l10n.calculationMethod,
                  value: _getMethodName(provider.method, l10n),
                  icon: Icons.calculate_outlined,
                  onTap: () => _showMethodPicker(context, provider, l10n),
                ),

                const Divider(height: 1, indent: 56, endIndent: 16),

                // 3. Локация (С вызовом диалога поиска!)
                _buildSettingsTile(
                  context,
                  title: l10n.location,
                  value: provider.isLoading
                      ? "..."
                      : (provider.isManualLocation
                      ? "${provider.city} (Manual)"
                      : "${provider.city} (Auto)"),
                  icon: provider.isManualLocation ? Icons.location_city : Icons.location_on_outlined,
                  onTap: () => _showLocationSearchSheet(context, provider),
                ),

                const Divider(height: 1, indent: 56, endIndent: 16),

                // 4. ТУМБЛЕР ОБЩИХ УВЕДОМЛЕНИЙ
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
                        size: 20
                    ),
                  ),
                  title: Text(
                      l10n.enableNotifications ?? "Push Notifications",
                      style: const TextStyle(fontWeight: FontWeight.w500)
                  ),
                  subtitle: Text(
                      l10n.enableNotificationsDesc ?? "Turn on/off all alerts",
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13)
                  ),
                  value: provider.notificationsEnabled,
                  onChanged: (bool value) async {
                    provider.toggleNotifications(value);
                    if (value) {
                      await NotificationService().requestPermissions();
                    }
                  },
                ),

                // --- СЕКЦИЯ: УМНЫЕ БУДИЛЬНИКИ ---
                if (provider.notificationsEnabled) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
                    child: Text(
                      l10n.smartAlarms?.toUpperCase() ?? "SMART ALARMS",
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.wb_twilight, color: Colors.white54, size: 24),
                    ),
                    title: Text(l10n.suhoorAlarm ?? "Suhoor Alarm", style: const TextStyle(fontSize: 15)),
                    trailing: _buildDropdown(
                      currentValue: provider.suhoorAlarmOffset,
                      onChanged: (val) => provider.updateSuhoorAlarm(val!),
                      l10n: l10n,
                    ),
                  ),

                  ListTile(
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.nights_stay_outlined, color: Colors.white54, size: 24),
                    ),
                    title: Text(l10n.iftarAlarm ?? "Iftar Alarm", style: const TextStyle(fontSize: 15)),
                    trailing: _buildDropdown(
                      currentValue: provider.iftarAlarmOffset,
                      onChanged: (val) => provider.updateIftarAlarm(val!),
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),

          // --- НОВОЕ: СЕКЦИЯ ABOUT & LEGAL (Для модераторов Apple и Play Console) ---
          _buildSectionHeader("About & Legal"),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildSimpleTile(
                  title: "Privacy Policy",
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _launchURL("https://sites.google.com/view/nurramadan"), // ЗАМЕНИТЬ НА СВОЮ ССЫЛКУ
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSimpleTile(
                  title: "Terms of Use (EULA)",
                  icon: Icons.gavel_outlined,
                  onTap: () => _launchURL("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"), // Стандартная Apple EULA
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildSimpleTile(
                  title: "App Version",
                  value: "1.0.0 (Build 1)",
                  icon: Icons.info_outline,
                  onTap: () {}, // Ничего не делает, просто инфо
                  showChevron: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
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
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value, style: const TextStyle(color: Colors.grey)),
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
      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
      items: [
        DropdownMenuItem(value: 0, child: Text(l10n.alarmOff ?? "Off")),
        DropdownMenuItem(value: 20, child: Text(l10n.alarm20Min ?? "20 min")),
        DropdownMenuItem(value: 30, child: Text(l10n.alarm30Min ?? "30 min")),
        DropdownMenuItem(value: 60, child: Text(l10n.alarm60Min ?? "60 min")),
      ],
      onChanged: onChanged,
    );
  }

  // --- МЕТОД ЗАПУСКА URL ---
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  // --- PICKERS (MODAL BOTTOM SHEETS) ---

  // Идентичный диалог поиска города с Главного экрана
  void _showLocationSearchSheet(BuildContext context, PrayerProvider provider) {
    final TextEditingController cityController = TextEditingController();
    final String lang = Localizations.localeOf(context).languageCode;

    final String title = lang == 'ru' ? "Изменить локацию" : "Change Location";
    final String hint = lang == 'ru' ? "Введите город (напр. Москва)" : "Enter city name (e.g. London)";
    final String btnSearch = lang == 'ru' ? "Найти" : "Search";
    final String btnGps = lang == 'ru' ? "Вернуть авто-определение (GPS)" : "Use Auto-Location (GPS)";

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
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                controller: cityController,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (cityController.text.trim().isNotEmpty) {
                      provider.setManualLocation(cityController.text.trim());
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(btnSearch, style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold, fontSize: 16)),
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
                    icon: const Icon(Icons.my_location, color: AppColors.primary),
                    label: Text(btnGps, style: const TextStyle(color: AppColors.primary)),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, PrayerProvider provider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(l10n.language, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _supportedLanguages.length,
                    itemBuilder: (context, index) {
                      final lang = _supportedLanguages[index];
                      final isSelected = provider.locale.languageCode == lang['code'];

                      return ListTile(
                        title: Text(lang['name']!),
                        trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
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

  void _showMadhabPicker(BuildContext context, PrayerProvider provider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(l10n.madhab, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: Text(l10n.madhabHanafi ?? "Hanafi"),
                trailing: provider.madhab == Madhab.hanafi ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  provider.updateMadhab(Madhab.hanafi);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(l10n.madhabStandard ?? "Standard"),
                subtitle: const Text("Shafi, Maliki, Hanbali"),
                trailing: provider.madhab == Madhab.shafi ? const Icon(Icons.check, color: AppColors.primary) : null,
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

  void _showMethodPicker(BuildContext context, PrayerProvider provider, AppLocalizations l10n) {
    final methods = [
      CalculationMethod.muslim_world_league,
      CalculationMethod.north_america,
      CalculationMethod.egyptian,
      CalculationMethod.umm_al_qura,
      CalculationMethod.turkey,
      CalculationMethod.karachi,
      CalculationMethod.dubai,
      CalculationMethod.singapore,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  child: Text(l10n.calculationMethod, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: methods.length,
                    itemBuilder: (ctx, index) {
                      final method = methods[index];
                      final isSelected = provider.method == method;

                      return ListTile(
                        title: Text(_getMethodName(method, l10n)),
                        trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
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
    if (madhab == Madhab.hanafi) return l10n.madhabHanafi ?? "Hanafi";
    return l10n.madhabStandard ?? "Standard";
  }

  String _getMethodName(CalculationMethod method, AppLocalizations l10n) {
    switch (method) {
      case CalculationMethod.muslim_world_league: return l10n.methodMWL ?? "MWL";
      case CalculationMethod.north_america: return l10n.methodISNA ?? "ISNA";
      case CalculationMethod.egyptian: return l10n.methodEgypt ?? "Egyptian";
      case CalculationMethod.umm_al_qura: return l10n.methodMakkah ?? "Umm Al-Qura";
      case CalculationMethod.karachi: return l10n.methodKarachi ?? "Karachi";
      case CalculationMethod.turkey: return l10n.methodTurkey ?? "Turkey";
      case CalculationMethod.dubai: return "Dubai";
      case CalculationMethod.singapore: return l10n.methodSingapore ?? "Singapore";
      case CalculationMethod.tehran: return l10n.methodTehran ?? "Tehran";
      default: return l10n.methodOther ?? "Other";
    }
  }
}