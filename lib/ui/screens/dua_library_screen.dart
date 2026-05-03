import 'dart:ui';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import 'dua_list_screen.dart'; // <--- Импорт экрана списка, который мы сделали

class DuaLibraryScreen extends StatelessWidget {
  const DuaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Используем чистые геттеры из локализации без хардкода
    final List<Map<String, dynamic>> categories = [
      {
        'id': 'morning_evening',
        'title': l10n.categoryMorningEvening,
        'icon': Icons.wb_twilight_rounded,
        'color': Colors.orangeAccent,
        'count': 1,
      },
      {
        'id': 'after_salah',
        'title': l10n.categoryAfterSalah,
        'icon': Icons.mosque_rounded,
        'color': Colors.tealAccent,
        'count': 1,
      },
      {
        'id': 'protection',
        'title': l10n.categoryProtection,
        'icon': Icons.shield_rounded,
        'color': Colors.blueAccent,
        'count': 1,
      },
      {
        'id': 'forgiveness',
        'title': l10n.categoryForgiveness,
        'icon': Icons.favorite_rounded,
        'color': Colors.redAccent,
        'count': 1,
      },
      {
        'id': 'family',
        'title': l10n.categoryFamily,
        'icon': Icons.family_restroom_rounded,
        'color': Colors.purpleAccent,
        'count': 0, // Пока пусто
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.duaLibraryTitle,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _buildCategoryCard(
            context: context,
            title: cat['title'],
            icon: cat['icon'],
            color: cat['color'],
            count: cat['count'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DuaListScreen(
                    categoryId: cat['id'],
                    categoryTitle: cat['title'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Icon(icon, size: 100, color: color.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$count", // Просто выводим цифру, сколько дуа внутри
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
