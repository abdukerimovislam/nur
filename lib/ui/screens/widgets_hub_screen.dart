import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/content/quran_quotes.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/prayer_tracker_provider.dart';
import 'nur_premium_screen.dart';

class WidgetsHubScreen extends StatelessWidget {
  const WidgetsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerProvider = context.watch<PrayerProvider>();
    final trackerProvider = context.watch<PrayerTrackerProvider>();
    final locale = prayerProvider.locale.languageCode;
    final daily = QuranQuotesRepository.dailyContent(
      date: DateTime.now(),
      languageCode: locale,
    );
    final nextPrayer = _resolveNextPrayer(prayerProvider);
    final stats = trackerProvider.getStatsForDate(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _InspireAtmosphere(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
              children: [
                const _InspireHeader(),
                const SizedBox(height: 20),
                _DailyQuoteHero(content: daily),
                const SizedBox(height: 18),
                _QuietSectionTitle(
                  title: 'Quran reflections',
                  action: '${QuranQuotesRepository.quotes.length} ayahs',
                ),
                const SizedBox(height: 12),
                _QuoteCollection(languageCode: locale),
                const SizedBox(height: 22),
                const _QuietSectionTitle(
                  title: 'Home & Lock Screen',
                  action: 'Nur widgets',
                ),
                const SizedBox(height: 12),
                _WidgetShelf(
                  nextPrayerName: nextPrayer.name,
                  nextPrayerTime: nextPrayer.time,
                  remaining: _formatShortDuration(
                    prayerProvider.timeRemaining.isNegative
                        ? Duration.zero
                        : prayerProvider.timeRemaining,
                  ),
                  streak: trackerProvider.currentStreak,
                  progressPercent: (stats.completionPercent * 100).round(),
                ),
                const SizedBox(height: 18),
                const _PremiumMoodCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _openPremium(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const NurPremiumScreen(),
      ),
    );
  }

  static void _showWidgetInstallHint(BuildContext context, String widgetName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Add "$widgetName" from iPhone widget gallery or Lock Screen customization.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  _NextPrayerInfo _resolveNextPrayer(PrayerProvider provider) {
    final times = provider.prayerTimes;
    if (times == null) {
      return const _NextPrayerInfo(name: 'Prayer', time: '--:--');
    }

    final now = DateTime.now();
    final prayers = [
      _PrayerCandidate('Fajr', times.fajr),
      _PrayerCandidate('Dhuhr', times.dhuhr),
      _PrayerCandidate('Asr', times.asr),
      _PrayerCandidate('Maghrib', times.maghrib),
      _PrayerCandidate('Isha', times.isha),
    ];

    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return _NextPrayerInfo(
          name: prayer.name,
          time: _formatTime(prayer.time),
        );
      }
    }

    return _NextPrayerInfo(
      name: 'Fajr',
      time: _formatTime(times.fajr.add(const Duration(days: 1))),
    );
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatShortDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours <= 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }
}

class _InspireAtmosphere extends StatelessWidget {
  const _InspireAtmosphere();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1B15),
            AppColors.background,
            Color(0xFF04100C),
          ],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _InspireHeader extends StatelessWidget {
  const _InspireHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NUR ISLAM HUB',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.8,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Inspire',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Quran, dua, prayer rhythm, and gentle reminders.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.24)),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _DailyQuoteHero extends StatelessWidget {
  const _DailyQuoteHero({
    required this.content,
  });

  final DailyQuranContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF173A2B),
            Color(0xFF0E241B),
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.24)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -10,
            child: Icon(
              Icons.format_quote_rounded,
              color: AppColors.primary.withOpacity(0.10),
              size: 118,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SoftBadge(
                icon: Icons.menu_book_rounded,
                label: 'AYAH OF THE DAY',
              ),
              const SizedBox(height: 24),
              Text(
                content.text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content.reference,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        content.dua,
                        style: const TextStyle(
                          color: AppColors.cream,
                          fontSize: 14,
                          height: 1.38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuietSectionTitle extends StatelessWidget {
  const _QuietSectionTitle({
    required this.title,
    required this.action,
  });

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _QuoteCollection extends StatelessWidget {
  const _QuoteCollection({
    required this.languageCode,
  });

  final String languageCode;

  @override
  Widget build(BuildContext context) {
    const quotes = QuranQuotesRepository.quotes;

    return SizedBox(
      height: 190,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: quotes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final localized = quotes[index].textFor(languageCode);
          return _QuoteTile(
            text: localized.text,
            reference: localized.reference,
          );
        },
      ),
    );
  }
}

class _QuoteTile extends StatelessWidget {
  const _QuoteTile({
    required this.text,
    required this.reference,
  });

  final String text;
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 246,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.80),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const Spacer(),
          Text(
            text,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reference,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetShelf extends StatelessWidget {
  const _WidgetShelf({
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.remaining,
    required this.streak,
    required this.progressPercent,
  });

  final String nextPrayerName;
  final String nextPrayerTime;
  final String remaining;
  final int streak;
  final int progressPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _WidgetMoodTile(
                icon: Icons.menu_book_rounded,
                title: 'Ayah',
                subtitle: 'Lock Screen',
                tag: 'Free',
                locked: false,
                onTap: () => WidgetsHubScreen._showWidgetInstallHint(
                  context,
                  'Nur Islam Ayah',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WidgetMoodTile(
                icon: Icons.timer_rounded,
                title: nextPrayerName,
                subtitle: '$nextPrayerTime • $remaining',
                tag: 'Premium',
                locked: true,
                onTap: () => WidgetsHubScreen._openPremium(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _WidgetMoodTile(
                icon: Icons.favorite_rounded,
                title: 'Dua',
                subtitle: 'Daily reminder',
                tag: 'Premium',
                locked: true,
                onTap: () => WidgetsHubScreen._openPremium(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _WidgetMoodTile(
                icon: Icons.check_circle_rounded,
                title: '$progressPercent% today',
                subtitle: '$streak day streak',
                tag: 'Premium',
                locked: true,
                onTap: () => WidgetsHubScreen._openPremium(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WidgetMoodTile extends StatelessWidget {
  const _WidgetMoodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.locked,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagColor = locked ? AppColors.primary : AppColors.emerald;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 148,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.82),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    locked ? Icons.lock_rounded : Icons.add_rounded,
                    color: locked ? AppColors.primary : AppColors.emerald,
                    size: 19,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumMoodCard extends StatelessWidget {
  const _PremiumMoodCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => WidgetsHubScreen._openPremium(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary.withOpacity(0.24)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  color: AppColors.primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalize the atmosphere',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Themes, fonts, and extended widget moods.',
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
              const SizedBox(width: 10),
              const Icon(
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

class _NextPrayerInfo {
  const _NextPrayerInfo({
    required this.name,
    required this.time,
  });

  final String name;
  final String time;
}

class _PrayerCandidate {
  const _PrayerCandidate(this.name, this.time);

  final String name;
  final DateTime time;
}
