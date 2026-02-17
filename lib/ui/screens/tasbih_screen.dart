import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../core/constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/tasbih_provider.dart';
import '../widgets/ad_banner_widget.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final List<_RippleModel> _ripples = [];
  bool _hasVibrator = false;

  @override
  void initState() {
    super.initState();
    _checkVibration();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  Future<void> _checkVibration() async {
    _hasVibrator = await Vibration.hasVibrator() == true;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    for (var ripple in _ripples) {
      ripple.controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(TasbihProvider provider, Offset tapPosition) {
    _scaleController.forward().then((_) => _scaleController.reverse());
    provider.increment();
    final int currentCount = provider.count;

    if (_hasVibrator) {
      if (currentCount % 99 == 0 && currentCount > 0) {
        Vibration.vibrate(pattern: [0, 150, 50, 150], amplitude: 255);
      } else if (currentCount % 33 == 0 && currentCount > 0) {
        Vibration.vibrate(duration: 100, amplitude: 200);
      } else {
        Vibration.vibrate(duration: 15, amplitude: 50);
      }
    } else {
      if (currentCount % 33 == 0) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }
    _addRipple(tapPosition);
  }

  void _addRipple(Offset position) {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final ripple = _RippleModel(position: position, controller: controller);
    setState(() => _ripples.add(ripple));
    controller.forward().then((_) {
      if (!mounted) {
        ripple.controller.dispose();
        return;
      }
      setState(() {
        _ripples.remove(ripple);
        ripple.controller.dispose();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TasbihProvider>();

    final List<String> dhikrs = [
      l10n.subhanAllah,
      l10n.alhamdulillah,
      l10n.allahuAkbar,
      l10n.astaghfirullah,
    ];

    final double cycleProgress = (provider.count % 33) / 33.0;
    final double displayProgress =
        (provider.count > 0 && provider.count % 33 == 0) ? 1.0 : cycleProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.tasbihTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: () => _showResetDialog(context, provider, l10n),
          ),
        ],
      ),
      body: Stack(
        children: [
          ..._ripples.map((ripple) => _buildRippleWidget(ripple)),
          Column(
            children: [
              // --- БАННЕР НАВЕРХУ ---
              const SafeArea(
                bottom: false,
                child: AdBannerWidget(),
              ),

              // 1. СЕКЦИЯ СЧЕТЧИКА
              Expanded(
                flex: 2,
                child: Center(
                  // ИСПРАВЛЕНИЕ: Обернули счетчик в FittedBox
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.count.toString(),
                            style: const TextStyle(
                              fontSize: 110,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                              letterSpacing: -4,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            l10n.total.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              letterSpacing: 4,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. СЕКЦИЯ СФЕРЫ (И КЛИКА)
              Expanded(
                flex: 4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          dhikrs[provider.selectedDhikrIndex],
                          key: ValueKey(provider.selectedDhikrIndex),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: GestureDetector(
                            onTapDown: (details) =>
                                _handleTap(provider, details.globalPosition),
                            behavior: HitTestBehavior.opaque,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildMainSphere(displayProgress),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. СЕКЦИЯ ВЫБОРА ЗИКРОВ
              Container(
                height: 100,
                padding: const EdgeInsets.only(bottom: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: dhikrs.length,
                  itemBuilder: (context, index) {
                    final isSelected = provider.selectedDhikrIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ChoiceChip(
                        label: Text(dhikrs[index]),
                        selected: isSelected,
                        onSelected: (_) {
                          HapticFeedback.lightImpact();
                          provider.selectDhikr(index);
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainSphere(double progress) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5),
              ],
            ),
          ),
          SizedBox(
            width: 230,
            height: 230,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _CircularProgressPainter(
                    progress: value,
                    color: AppColors.primary,
                    backgroundColor: Colors.white10,
                  ),
                );
              },
            ),
          ),
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, 10)),
                ]),
            child: const Center(
              child: Icon(Icons.touch_app_rounded,
                  size: 60, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRippleWidget(_RippleModel ripple) {
    return AnimatedBuilder(
      animation: ripple.controller,
      builder: (context, child) {
        final double size = 100 + (400 * ripple.controller.value);
        final double opacity = 1.0 - ripple.controller.value;

        return Positioned(
          left: ripple.position.dx - (size / 2),
          top: ripple.position.dy - (size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(opacity * 0.5),
                width: 2,
              ),
              color: AppColors.primary.withOpacity(opacity * 0.1),
            ),
          ),
        );
      },
    );
  }

  void _showResetDialog(
      BuildContext context, TasbihProvider provider, AppLocalizations l10n) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.reset, style: const TextStyle(color: Colors.white)),
        content: Text(l10n.resetConfirm,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              provider.reset();
              Navigator.pop(ctx);
            },
            child: const Text("RESET",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _RippleModel {
  final Offset position;
  final AnimationController controller;
  _RippleModel({required this.position, required this.controller});
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
