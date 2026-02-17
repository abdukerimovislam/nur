import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/app_colors.dart';

// ИСПРАВЛЕНИЕ: Добавлен миксин KeepAlive, чтобы виджет не уничтожался при скролле
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _hasError = false;

  // Указываем Flutter, что состояние этого виджета нужно беречь при скролле
  @override
  bool get wantKeepAlive => true;

  String get adUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-7039790177400209/2798797263'
          : 'ca-app-pub-7039790177400209/5348938981';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('AdMob: Banner loaded successfully.');
          if (!mounted || ad != _bannerAd) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _hasError = false;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('AdMob: Banner failed to load: $err');
          ad.dispose();
          if (mounted) {
            setState(() => _hasError = true);
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ОБЯЗАТЕЛЬНЫЙ ВЫЗОВ для AutomaticKeepAliveClientMixin
    super.build(context);

    if (_hasError) {
      return const SizedBox.shrink();
    }

    if (_isLoaded && _bannerAd != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary.withOpacity(0.3),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}