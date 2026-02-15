import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/dua_repository.dart';

class DuaListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const DuaListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Map<String, String>> duas = DuaRepository.getDuasByCategory(categoryId, l10n);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(categoryTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: duas.isEmpty
          ? const Center(child: Text("Coming Soon...", style: TextStyle(color: Colors.white24)))
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: duas.length,
        itemBuilder: (context, index) => _DuaExpandableCard(dua: duas[index], l10n: l10n),
      ),
    );
  }
}

class _DuaExpandableCard extends StatelessWidget {
  final Map<String, String> dua;
  final AppLocalizations l10n;

  const _DuaExpandableCard({required this.dua, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primary,
          collapsedIconColor: Colors.white30,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            dua['title']!,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // 1. Арабский оригинал
                  Text(
                    dua['arabic']!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        height: 1.8,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Транскрипция
                  _buildSection(context, l10n.transcription, dua['trans']!, isItalic: true),

                  const SizedBox(height: 16),

                  // 3. Перевод
                  _buildSection(context, l10n.translation, dua['translate']!, color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String label, String content, {bool isItalic = false, Color color = Colors.white60}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                label.toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.copied),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    )
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white24),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: color,
            fontSize: 14,
            height: 1.6,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}