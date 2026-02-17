import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import 'package:adhan/adhan.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/prayer_provider.dart';
import '../../core/constants/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  final bool isActive;
  final VoidCallback onMoveBack;

  const QiblaScreen({
    super.key,
    required this.isActive,
    required this.onMoveBack,
  });

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasVibrated = false;
  bool _isProcessing = false;

  // Переменные для математического сглаживания компаса
  double? _smoothedHeading;
  bool _isAlignedHysteresis = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    if (widget.isActive) {
      _initializeCamera();
    }
  }

  @override
  void didUpdateWidget(covariant QiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _initializeCamera();
      } else {
        _disposeCamera();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isProcessing || _isCameraInitialized || !mounted) return;
    _isProcessing = true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty || !mounted) return;

      final controller = CameraController(
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first),
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Camera Init Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _disposeCamera() async {
    if (_isProcessing || !_isCameraInitialized) return;
    _isProcessing = true;

    try {
      final controller = _cameraController;
      if (controller != null) {
        _cameraController = null;
        if (mounted) {
          setState(() => _isCameraInitialized = false);
        }
        await Future.delayed(const Duration(milliseconds: 100));
        await controller.dispose();
      }
    } catch (e) {
      debugPrint("Camera Dispose Silent Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrayerProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (provider.prayerTimes == null) return const Scaffold(backgroundColor: AppColors.background);
    final qiblaDirection = Qibla(provider.prayerTimes!.coordinates).direction;

    final bool canShowCamera = widget.isActive &&
        _isCameraInitialized &&
        _cameraController != null &&
        _cameraController!.value.isInitialized &&
        _cameraController!.value.aspectRatio > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          if (canShowCamera)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _cameraController!.value.aspectRatio,
                child: CameraPreview(_cameraController!),
              ),
            )
          else
            Container(color: AppColors.background),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.transparent, AppColors.background.withOpacity(0.8)],
                ),
              ),
            ),
          ),

          if (widget.isActive)
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

                // ИСПРАВЛЕНИЕ: Фильтр нижних частот (EMA) для устранения аппаратной тряски сенсора
                final rawHeading = snapshot.data?.heading ?? 0.0;
                if (_smoothedHeading == null) {
                  _smoothedHeading = rawHeading;
                } else {
                  double diff = rawHeading - _smoothedHeading!;
                  if (diff > 180) diff -= 360;
                  if (diff < -180) diff += 360;
                  // Коэффициент 0.15 создает идеальную плавность стрелки
                  _smoothedHeading = _smoothedHeading! + (diff * 0.15);
                  if (_smoothedHeading! < 0) _smoothedHeading = _smoothedHeading! + 360;
                  if (_smoothedHeading! >= 360) _smoothedHeading = _smoothedHeading! - 360;
                }

                final heading = _smoothedHeading!;

                double diffToQibla = (qiblaDirection - heading).abs();
                if (diffToQibla > 180) diffToQibla = 360 - diffToQibla;

                // ИСПРАВЛЕНИЕ: Логика гистерезиса, чтобы экран не "моргал" при дрожании рук на границе угла
                if (diffToQibla < 2.5) {
                  _isAlignedHysteresis = true;
                } else if (diffToQibla > 4.5) {
                  _isAlignedHysteresis = false;
                }

                final bool isAligned = _isAlignedHysteresis;

                if (isAligned && !_hasVibrated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    HapticFeedback.mediumImpact();
                  });
                  _hasVibrated = true;
                } else if (!isAligned) {
                  _hasVibrated = false;
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildRadarRings(isAligned),
                    _buildKaabaMarker(heading, qiblaDirection, isAligned, l10n),
                    _buildTopPanel(provider, isAligned, l10n),
                    _buildBottomInfo(l10n, qiblaDirection, isAligned),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTopPanel(PrayerProvider provider, bool isAligned, AppLocalizations l10n) {
    return Positioned(
      top: 60, left: 20, right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white.withOpacity(0.05),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: widget.onMoveBack,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.city.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                        isAligned ? l10n.qiblaAligned : l10n.qiblaSearching,
                        style: TextStyle(color: isAligned ? AppColors.primary : Colors.white54, fontSize: 11)
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.gps_fixed, color: isAligned ? AppColors.primary : Colors.white30, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadarRings(bool isAligned) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(2, (index) {
            double progress = (_pulseController.value + (index * 0.5)) % 1.0;
            return Container(
              width: 150 + (progress * 250),
              height: 150 + (progress * 250),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isAligned ? AppColors.primary : Colors.white).withOpacity(1 - progress),
                  width: 1.5,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildNativeKaaba(bool isAligned) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAligned ? AppColors.primary.withOpacity(0.8) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 8,
            width: double.infinity,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(height: 3),
          Container(
            height: 1.5,
            width: double.infinity,
            color: const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  Widget _buildKaabaMarker(double heading, double qibla, bool isAligned, AppLocalizations l10n) {
    double offset = qibla - heading;
    if (offset > 180) offset -= 360;
    if (offset < -180) offset += 360;

    double horizontalAlignment = (offset / 30).clamp(-1.5, 1.5);

    return AnimatedAlign(
      duration: const Duration(milliseconds: 150),
      curve: Curves.decelerate,
      alignment: Alignment(horizontalAlignment, 0),
      child: Opacity(
        opacity: (1 - (offset.abs() / 40)).clamp(0.0, 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 120, width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: (isAligned ? AppColors.primary : Colors.white).withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 2
                  )
                ],
              ),
              child: Center(
                child: _buildNativeKaaba(isAligned),
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), border: Border.all(color: Colors.white12)),
                  child: Text(
                      l10n.holyKaaba.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 4, fontSize: 13)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(AppLocalizations l10n, double qibla, bool isAligned) {
    return Positioned(
      bottom: 80,
      child: Column(
        children: [
          Text("${qibla.toStringAsFixed(0)}°", style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w200)),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: isAligned ? AppColors.primary : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
                isAligned ? l10n.qiblaAligned : l10n.rotatePhone,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
            ),
          ),
        ],
      ),
    );
  }
}