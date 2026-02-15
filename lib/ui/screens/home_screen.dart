import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../l10n/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/dua_bottom_sheet.dart';
import '../widgets/daily_inspiration_card.dart';
import '../widgets/ad_banner_widget.dart';
import 'dua_library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ИСПРАВЛЕНИЕ: Убрали bottomNavigationBar, баннер перенесен в тело экрана

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const DuaLibraryScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 8,
        icon: const Icon(Icons.menu_book_rounded, color: AppColors.background),
        label: Text(
          l10n.duaLibraryTitle,
          style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Consumer<PrayerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            if (provider.error != null) {
              return _buildErrorState(context, provider, l10n);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                if (!provider.isManualLocation) {
                  await provider.init();
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 100), // Слегка уменьшили нижний отступ, так как баннера там больше нет
                children: [
                  _buildHeader(context, provider), // Это наш "AppBar"

                  const SizedBox(height: 24),

                  // --- БАННЕР ТЕПЕРЬ ЗДЕСЬ (ПОД ШАПКОЙ) ---
                  const AdBannerWidget(),

                  const SizedBox(height: 24),

                  _buildArcTimer(provider, l10n),

                  const SizedBox(height: 32),

                  const DailyInspirationCard(),

                  const SizedBox(height: 32),

                  _buildBiologyCard(provider, l10n),

                  const SizedBox(height: 24),

                  _buildFastingTimes(context, provider, l10n),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ---

  Widget _buildErrorState(BuildContext context, PrayerProvider provider, AppLocalizations l10n) {
    final String lang = Localizations.localeOf(context).languageCode;
    final String searchBtnTitle = lang == 'ru' ? "Выбрать город вручную" : "Search City Manually";

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _showLocationSearchSheet(context, provider),
              icon: const Icon(Icons.search, color: AppColors.background),
              label: Text(
                searchBtnTitle,
                style: const TextStyle(color: AppColors.background, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => provider.init(),
              icon: const Icon(Icons.refresh, color: Colors.white54),
              label: Text(l10n.refresh, style: const TextStyle(color: Colors.white54)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PrayerProvider provider) {
    final locale = Localizations.localeOf(context).languageCode;
    final String formattedDate = DateFormat('EEEE, d MMMM', locale).format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate.toUpperCase(),
                style: TextStyle(
                  color: AppColors.primary.withOpacity(0.8),
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showLocationSearchSheet(context, provider),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                            provider.isManualLocation ? Icons.location_city : Icons.location_on,
                            color: provider.isManualLocation ? AppColors.primary : Colors.white,
                            size: 20
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "${provider.city}, ${provider.country}",
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Окно поиска города ---
  void _showLocationSearchSheet(BuildContext context, PrayerProvider provider) {
    final TextEditingController cityController = TextEditingController();
    final String lang = Localizations.localeOf(context).languageCode;

    // Временные адаптивные переводы
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
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
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

  Widget _buildArcTimer(PrayerProvider provider, AppLocalizations l10n) {
    final duration = provider.timeRemaining;
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    final isFasting = provider.currentEvent == RamadanEvent.iftar;
    final eventText = isFasting ? l10n.untilIftar : l10n.untilSuhoor;

    final startIcon = isFasting ? Icons.wb_twilight : Icons.nights_stay;
    final endIcon = isFasting ? Icons.nights_stay : Icons.wb_twilight;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: const Size(320, 160),
                  painter: ArcProgressPainter(
                    progress: provider.progress,
                    activeColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: Column(
                  children: [
                    Text(
                      eventText.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$hours:$minutes:$seconds",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 10,
                child: Icon(startIcon, color: AppColors.textSecondary, size: 28),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Icon(endIcon, color: AppColors.primary, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBiologyCard(PrayerProvider provider, AppLocalizations l10n) {
    final isFasting = provider.currentEvent == RamadanEvent.iftar;
    final elapsedHours = provider.timeElapsed.inHours;

    String title;
    String desc;
    IconData icon;
    Color color;

    if (!isFasting) {
      title = l10n.bioNightTitle;
      desc = l10n.bioNightDesc;
      icon = Icons.water_drop_outlined;
      color = Colors.blueAccent;
    } else {
      if (elapsedHours < 4) {
        title = l10n.bioPhase1Title;
        desc = l10n.bioPhase1Desc;
        icon = Icons.monitor_heart_outlined;
        color = Colors.greenAccent;
      } else if (elapsedHours < 8) {
        title = l10n.bioPhase2Title;
        desc = l10n.bioPhase2Desc;
        icon = Icons.spa_outlined;
        color = Colors.tealAccent;
      } else if (elapsedHours < 12) {
        title = l10n.bioPhase3Title;
        desc = l10n.bioPhase3Desc;
        icon = Icons.local_fire_department_outlined;
        color = Colors.orangeAccent;
      } else {
        title = l10n.bioPhase4Title;
        desc = l10n.bioPhase4Desc;
        icon = Icons.autorenew;
        color = AppColors.primary;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bioTitle.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastingTimes(BuildContext context, PrayerProvider provider, AppLocalizations l10n) {
    final times = provider.prayerTimes;
    if (times == null) return const SizedBox.shrink();

    final suhoorTime = DateFormat.Hm().format(times.fajr);
    final iftarTime = DateFormat.Hm().format(times.maghrib);

    return Row(
      children: [
        Expanded(
          child: _buildTimeCard(
            context: context,
            title: l10n.suhoor,
            time: suhoorTime,
            icon: Icons.wb_twilight,
            l10n: l10n,
            isSuhoor: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimeCard(
            context: context,
            title: l10n.iftar,
            time: iftarTime,
            icon: Icons.nights_stay_outlined,
            l10n: l10n,
            isSuhoor: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required BuildContext context,
    required String title,
    required String time,
    required IconData icon,
    required AppLocalizations l10n,
    required bool isSuhoor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => DuaBottomSheet.show(context, isSuhoor: isSuhoor),
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.primary.withOpacity(0.1),
        highlightColor: AppColors.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        l10n.tapForDua,
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;

  ArcProgressPainter({
    required this.progress,
    required this.activeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..shader = SweepGradient(
        colors: [activeColor.withOpacity(0.5), activeColor],
        startAngle: pi,
        endAngle: pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(rect, pi, pi, false, backgroundPaint);
    canvas.drawArc(rect, pi, pi * progress, false, activePaint);

    final dotAngle = pi + (pi * progress);
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    final dotPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()
      ..color = activeColor.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(Offset(dotX, dotY), 12, glowPaint);
    canvas.drawCircle(Offset(dotX, dotY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}