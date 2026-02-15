import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';

class DuaBottomSheet {
  /// Статический метод для вызова BottomSheet из любой точки приложения
  static void show(BuildContext context, {required bool isSuhoor}) {
    final l10n = AppLocalizations.of(context)!;

    final title = isSuhoor ? l10n.duaSuhoorTitle : l10n.duaIftarTitle;
    final arabic = isSuhoor ? l10n.duaSuhoorArabic : l10n.duaIftarArabic;
    final translit = isSuhoor ? l10n.duaSuhoorTranslit : l10n.duaIftarTranslit;
    final transl = isSuhoor ? l10n.duaSuhoorTransl : l10n.duaIftarTransl;
    final headerIcon = isSuhoor ? Icons.wb_twilight : Icons.nights_stay_outlined;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(headerIcon, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              Text(
                arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    fontSize: 28,
                    height: 1.6,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              Text(
                translit,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                transl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}