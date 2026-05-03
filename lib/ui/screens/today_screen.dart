import 'dart:ui';

import 'package:adhan/adhan.dart' hide Prayer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/content/quran_quotes.dart';
import '../../data/services/nur_widget_service.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/prayer_tracker_provider.dart';
import '../widgets/ad_banner_widget.dart';
import 'dua_library_screen.dart';
import 'nur_premium_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const DuaLibraryScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        icon: const Icon(
          Icons.menu_book_rounded,
          color: AppColors.background,
        ),
        label: const Text(
          'Duas',
          style: TextStyle(
            color: AppColors.background,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer2<PrayerProvider, PrayerTrackerProvider>(
          builder: (context, prayerProvider, trackerProvider, child) {
            if (prayerProvider.isLoading || trackerProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (prayerProvider.error != null) {
              return _TodayErrorState(
                error: prayerProvider.error!,
                onRetry: prayerProvider.init,
              );
            }

            _syncNativeWidgets(
              prayerProvider: prayerProvider,
              trackerProvider: trackerProvider,
            );
            final dailyContent = QuranQuotesRepository.dailyContent(
              date: DateTime.now(),
              languageCode: prayerProvider.locale.languageCode,
            );

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                await prayerProvider.init();

                _syncNativeWidgets(
                  prayerProvider: prayerProvider,
                  trackerProvider: trackerProvider,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                children: [
                  _TodayHeader(prayerProvider: prayerProvider),
                  const SizedBox(height: 20),
                  _NextPrayerHero(prayerProvider: prayerProvider),
                  const SizedBox(height: 18),
                  const _PremiumEntryCard(),
                  const SizedBox(height: 18),
                  const AdBannerWidget(),
                  const SizedBox(height: 18),
                  _PrayerChecklistCard(
                    prayerProvider: prayerProvider,
                    trackerProvider: trackerProvider,
                  ),
                  const SizedBox(height: 18),
                  _StatsGrid(trackerProvider: trackerProvider),
                  const SizedBox(height: 18),
                  const _QuranAICard(),
                  const SizedBox(height: 18),
                  _DailyAyahCard(content: dailyContent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static void _syncNativeWidgets({
    required PrayerProvider prayerProvider,
    required PrayerTrackerProvider trackerProvider,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final next = _resolveNextPrayerForWidget(prayerProvider.prayerTimes);
      final duration = prayerProvider.timeRemaining.isNegative
          ? Duration.zero
          : prayerProvider.timeRemaining;
      final stats = trackerProvider.getStatsForDate(DateTime.now());

      NurWidgetService.updatePrayerWidget(
        nextPrayerName: next.name,
        nextPrayerTime: next.time,
        nextPrayerDate: next.date,
        timeRemaining: _formatDurationForWidget(duration),
        city: prayerProvider.city.trim().isEmpty ? 'Nur' : prayerProvider.city,
        streak: trackerProvider.currentStreak,
        todayProgressPercent: (stats.completionPercent * 100).round(),
      );

      final dailyContent = QuranQuotesRepository.dailyContent(
        date: DateTime.now(),
        languageCode: prayerProvider.locale.languageCode,
      );
      NurWidgetService.updateDailyContentWidget(
        ayahText: dailyContent.text,
        ayahReference: dailyContent.reference,
        duaText: dailyContent.dua,
      );
    });
  }

  static _NurWidgetPrayerInfo _resolveNextPrayerForWidget(PrayerTimes? times) {
    if (times == null) {
      return _NurWidgetPrayerInfo(
        name: 'Prayer',
        time: '--:--',
        date: DateTime.now().add(const Duration(hours: 1)),
      );
    }

    final now = DateTime.now();

    final prayers = [
      _NurWidgetPrayerCandidate('Fajr', times.fajr),
      _NurWidgetPrayerCandidate('Dhuhr', times.dhuhr),
      _NurWidgetPrayerCandidate('Asr', times.asr),
      _NurWidgetPrayerCandidate('Maghrib', times.maghrib),
      _NurWidgetPrayerCandidate('Isha', times.isha),
    ];

    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return _NurWidgetPrayerInfo(
          name: prayer.name,
          time: _formatTimeForWidget(prayer.time),
          date: prayer.time,
        );
      }
    }

    final tomorrowFajr = times.fajr.add(const Duration(days: 1));
    return _NurWidgetPrayerInfo(
      name: 'Fajr',
      time: _formatTimeForWidget(tomorrowFajr),
      date: tomorrowFajr,
    );
  }

  static String _formatTimeForWidget(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDurationForWidget(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class _PremiumEntryCard extends StatelessWidget {
  const _PremiumEntryCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const NurPremiumScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.28),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock Nur Premium',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Quran AI, widgets and advanced prayer analytics.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({
    required this.prayerProvider,
  });

  final PrayerProvider prayerProvider;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greetingForHour(now.hour);
    final location = prayerProvider.city.trim().isEmpty
        ? 'Location detected'
        : prayerProvider.country.trim().isEmpty
            ? prayerProvider.city
            : '${prayerProvider.city}, ${prayerProvider.country}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NUR ISLAM HUB',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.textSecondary,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ],
    );
  }

  String _greetingForHour(int hour) {
    if (hour >= 4 && hour < 12) return 'Assalamu alaikum';
    if (hour >= 12 && hour < 18) return 'Keep your prayer habit';
    return 'End the day with dhikr';
  }
}

class _NextPrayerHero extends StatelessWidget {
  const _NextPrayerHero({
    required this.prayerProvider,
  });

  final PrayerProvider prayerProvider;

  @override
  Widget build(BuildContext context) {
    final next = _resolveNextPrayer(prayerProvider.prayerTimes);
    final duration = prayerProvider.timeRemaining.isNegative
        ? Duration.zero
        : prayerProvider.timeRemaining;

    final formattedDuration = _formatDuration(duration);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceAlt,
            AppColors.surface,
          ],
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            top: -36,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEXT PRAYER',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      next.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                  Text(
                    next.time,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '$formattedDuration remaining',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: prayerProvider.progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white10,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _NextPrayer _resolveNextPrayer(PrayerTimes? times) {
    if (times == null) {
      return const _NextPrayer(name: 'Prayer', time: '--:--');
    }

    final now = DateTime.now();

    final prayers = <_NextPrayerCandidate>[
      _NextPrayerCandidate('Fajr', times.fajr),
      _NextPrayerCandidate('Dhuhr', times.dhuhr),
      _NextPrayerCandidate('Asr', times.asr),
      _NextPrayerCandidate('Maghrib', times.maghrib),
      _NextPrayerCandidate('Isha', times.isha),
    ];

    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return _NextPrayer(
          name: prayer.name,
          time: _formatTime(prayer.time),
        );
      }
    }

    return _NextPrayer(
      name: 'Fajr',
      time: _formatTime(times.fajr.add(const Duration(days: 1))),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _PrayerChecklistCard extends StatelessWidget {
  const _PrayerChecklistCard({
    required this.prayerProvider,
    required this.trackerProvider,
  });

  final PrayerProvider prayerProvider;
  final PrayerTrackerProvider trackerProvider;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final stats = trackerProvider.getStatsForDate(today);
    final times = prayerProvider.prayerTimes;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Today’s prayers',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${stats.completedCount}/5',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final prayer in trackerProvider.prayerOrder) ...[
            _PrayerChecklistTile(
              prayer: prayer,
              time: _timeForPrayer(times, prayer),
              isCompleted: trackerProvider.isPrayerCompleted(today, prayer),
              onTap: () async {
                await trackerProvider.togglePrayer(today, prayer);

                TodayScreen._syncNativeWidgets(
                  prayerProvider: prayerProvider,
                  trackerProvider: trackerProvider,
                );
              },
            ),
            if (prayer != PrayerName.isha) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  String _timeForPrayer(PrayerTimes? times, PrayerName prayer) {
    if (times == null) return '--:--';

    late final DateTime dateTime;

    switch (prayer) {
      case PrayerName.fajr:
        dateTime = times.fajr;
        break;
      case PrayerName.dhuhr:
        dateTime = times.dhuhr;
        break;
      case PrayerName.asr:
        dateTime = times.asr;
        break;
      case PrayerName.maghrib:
        dateTime = times.maghrib;
        break;
      case PrayerName.isha:
        dateTime = times.isha;
        break;
    }

    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _PrayerChecklistTile extends StatelessWidget {
  const _PrayerChecklistTile({
    required this.prayer,
    required this.time,
    required this.isCompleted,
    required this.onTap,
  });

  final PrayerName prayer;
  final String time;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isCompleted
        ? AppColors.emerald.withOpacity(0.15)
        : AppColors.background.withOpacity(0.42);

    final borderColor =
        isCompleted ? AppColors.emerald.withOpacity(0.45) : AppColors.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.emerald : Colors.transparent,
                  border: Border.all(
                    color:
                        isCompleted ? AppColors.emerald : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : Icons.add_rounded,
                  color:
                      isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  prayer.englishName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.trackerProvider,
  });

  final PrayerTrackerProvider trackerProvider;

  @override
  Widget build(BuildContext context) {
    final todayStats = trackerProvider.getStatsForDate(DateTime.now());
    final weakest = trackerProvider.weakestPrayer;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Streak',
                value: '${trackerProvider.currentStreak}',
                subtitle: 'perfect days',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Today',
                value: '${(todayStats.completionPercent * 100).round()}%',
                subtitle: 'completed',
                icon: Icons.task_alt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Week',
                value:
                    '${(trackerProvider.weeklyCompletionPercent * 100).round()}%',
                subtitle: 'completion',
                icon: Icons.insights_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Weakest',
                value: weakest?.englishName ?? '—',
                subtitle: 'needs focus',
                icon: Icons.auto_graph_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranAICard extends StatelessWidget {
  const _QuranAICard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const NurPremiumScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withOpacity(0.24)),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quran AI Tutor',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Practice recitation with AI feedback. Unlock with Premium.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyAyahCard extends StatelessWidget {
  const _DailyAyahCard({
    required this.content,
  });

  final DailyQuranContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AYAH OF THE DAY',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            content.text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              height: 1.28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content.reference,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayErrorState extends StatelessWidget {
  const _TodayErrorState({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_rounded,
              color: AppColors.primary,
              size: 58,
            ),
            const SizedBox(height: 18),
            const Text(
              'Location is needed',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try again',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayer {
  const _NextPrayer({
    required this.name,
    required this.time,
  });

  final String name;
  final String time;
}

class _NextPrayerCandidate {
  const _NextPrayerCandidate(this.name, this.time);

  final String name;
  final DateTime time;
}

class _NurWidgetPrayerInfo {
  const _NurWidgetPrayerInfo({
    required this.name,
    required this.time,
    required this.date,
  });

  final String name;
  final String time;
  final DateTime date;
}

class _NurWidgetPrayerCandidate {
  const _NurWidgetPrayerCandidate(this.name, this.time);

  final String name;
  final DateTime time;
}
