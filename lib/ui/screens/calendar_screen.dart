import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:adhan/adhan.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/tracker_provider.dart';
import '../../core/constants/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isSharing = false;

  final GlobalKey _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _captureAndShareImage(TrackerProvider tracker, AppLocalizations l10n) async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    HapticFeedback.lightImpact();

    try {
      final RenderRepaintBoundary boundary = _shareCardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/nur_ramadan_progress.png').create();
        await imagePath.writeAsBytes(pngBytes);

        final text = l10n.shareProgress(tracker.fastedCount, tracker.missedCount);
        await Share.shareXFiles([XFile(imagePath.path)], text: text);
      }
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ИСПРАВЛЕНИЕ FPS: Используем select, чтобы экран не перерисовывался каждую секунду от таймера PrayerProvider!
    final isPrayerLoading = context.select<PrayerProvider, bool>((p) => p.isLoading);
    final String currentCity = context.select<PrayerProvider, String>((p) => p.city);
    final prayerProvider = context.read<PrayerProvider>(); // Читаем методы без подписки на таймер

    final trackerProvider = context.watch<TrackerProvider>();
    final l10n = AppLocalizations.of(context)!;

    final String langCode = Localizations.localeOf(context).languageCode;
    final String hijriLocale = (langCode == 'ar' || langCode == 'id') ? langCode : 'en';
    HijriCalendar.setLocal(hijriLocale);

    if (isPrayerLoading || trackerProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final selectedPrayerTimes = _selectedDay != null
        ? prayerProvider.getPrayerTimesForDate(_selectedDay!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.navCalendar, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : const Icon(Icons.ios_share_rounded, color: AppColors.primary),
            onPressed: () => _captureAndShareImage(trackerProvider, l10n),
            tooltip: 'Share',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -2000,
            left: 0,
            child: RepaintBoundary(
              key: _shareCardKey,
              child: _buildShareableCard(trackerProvider.fastedCount, l10n),
            ),
          ),

          ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _buildTableCalendar(langCode, trackerProvider),

              if (_selectedDay != null)
                _buildFastingTrackerCard(_selectedDay!, trackerProvider, l10n),

              if (_selectedDay != null)
                _buildHijriRow(_selectedDay!, l10n),

              _buildPrayerList(selectedPrayerTimes, l10n, langCode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareableCard(int fastedCount, AppLocalizations l10n) {
    return Container(
      width: 400, height: 450,
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(30)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -50, right: -50,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 100)]),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.nights_stay_rounded, color: AppColors.primary, size: 60),
              const SizedBox(height: 20),
              Text(l10n.shareImageTitle.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2), textAlign: TextAlign.center),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2)),
                child: Column(
                  children: [
                    Text(fastedCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w200, height: 1.1)),
                    Text(l10n.shareImageDays.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(l10n.shareImageApp, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar(String locale, TrackerProvider tracker) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
      child: TableCalendar(
        locale: locale,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        currentDay: DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final status = tracker.getStatusForDate(date);
            if (status == FastingStatus.none) return null;
            final color = status == FastingStatus.fasted ? AppColors.primary : Colors.redAccent;
            return Positioned(
              bottom: 6,
              child: Container(
                width: 6, height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)]),
              ),
            );
          },
        ),
        calendarStyle: const CalendarStyle(
          defaultTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.white70),
          outsideTextStyle: TextStyle(color: Colors.white24),
          todayDecoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false, titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFastingTrackerCard(DateTime date, TrackerProvider tracker, AppLocalizations l10n) {
    final status = tracker.getStatusForDate(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    final bool canEdit = !selectedDate.isAfter(today);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.fastingStatus,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                if (!canEdit)
                  const Icon(Icons.lock_outline, color: Colors.white30, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: canEdit ? 1.0 : 0.5,
              child: Row(
                children: [
                  _buildStatusButton(
                    title: l10n.statusFasted,
                    icon: Icons.check_circle_rounded,
                    activeColor: AppColors.primary,
                    isSelected: status == FastingStatus.fasted,
                    onTap: () {
                      if (!canEdit) return _showLockMessage(context, l10n);
                      HapticFeedback.selectionClick();
                      tracker.setDayStatus(date, FastingStatus.fasted);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatusButton(
                    title: l10n.statusMissed,
                    icon: Icons.cancel_rounded,
                    activeColor: Colors.redAccent,
                    isSelected: status == FastingStatus.missed,
                    onTap: () {
                      if (!canEdit) return _showLockMessage(context, l10n);
                      HapticFeedback.selectionClick();
                      tracker.setDayStatus(date, FastingStatus.missed);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatusButton(
                    title: l10n.statusNotSet,
                    icon: Icons.radio_button_unchecked_rounded,
                    activeColor: Colors.white54,
                    isSelected: status == FastingStatus.none,
                    onTap: () {
                      if (!canEdit) return _showLockMessage(context, l10n);
                      HapticFeedback.selectionClick();
                      tracker.setDayStatus(date, FastingStatus.none);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockMessage(BuildContext context, AppLocalizations l10n) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.futureDateError, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatusButton({
    required String title,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? activeColor.withOpacity(0.5) : Colors.white10,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: isSelected ? activeColor : Colors.white30, size: 24),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? activeColor : Colors.white70,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHijriRow(DateTime date, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.nights_stay_outlined, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(_formatHijriDate(date, l10n), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerList(dynamic times, AppLocalizations l10n, String langCode) {
    if (times == null) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: Icon(Icons.location_off, color: Colors.white24, size: 40)),
      );
    }

    final sunnahTimes = SunnahTimes(times);
    final tahajjudTime = sunnahTimes.lastThirdOfTheNight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildRow(l10n.tahajjud, tahajjudTime, isSecondary: true),
          _buildRow(l10n.fajr, times.fajr, isHighlight: true),
          _buildRow(l10n.sunrise, times.sunrise, isSecondary: true),
          _buildRow(l10n.dhuhr, times.dhuhr),
          _buildRow(l10n.asr, times.asr),
          _buildRow(l10n.maghrib, times.maghrib, isHighlight: true),
          _buildRow(l10n.isha, times.isha),
        ],
      ),
    );
  }

  String _formatHijriDate(DateTime date, AppLocalizations l10n) {
    try {
      final hijri = HijriCalendar.fromDate(date);
      return "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";
    } catch (e) { return "-- -- ----"; }
  }

  Widget _buildRow(String name, DateTime time, {bool isHighlight = false, bool isSecondary = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isHighlight ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: isSecondary ? Colors.orangeAccent : (isHighlight ? AppColors.primary : Colors.white70), fontSize: 16, fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500)),
          Text(DateFormat.Hm().format(time), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}