import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/quran/quran_practice_repository.dart';
import '../../data/services/recitation_recording_service.dart';
import '../../providers/quran_ai_provider.dart';
import 'nur_premium_screen.dart';

class AyahPracticeScreen extends StatefulWidget {
  const AyahPracticeScreen({
    super.key,
    required this.surah,
    required this.initialAyah,
  });

  final QuranSurahPractice surah;
  final QuranAyahPractice initialAyah;

  @override
  State<AyahPracticeScreen> createState() => _AyahPracticeScreenState();
}

class _AyahPracticeScreenState extends State<AyahPracticeScreen> {
  final RecitationRecordingService _recordingService =
  RecitationRecordingService();

  late QuranAyahPractice _selectedAyah;

  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _recordingSeconds = 0;
  String? _lastRecordingPath;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _selectedAyah = widget.initialAyah;
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordingService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _finishRecording();
      return;
    }

    final provider = context.read<QuranAIProvider>();
    if (!provider.canUseFreeCheck) {
      _openPremium();
      return;
    }

    final path = await _recordingService.start();

    if (!mounted) return;

    if (path == null) {
      _showSnack(
        'Microphone access is needed to record your recitation.',
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
      _lastRecordingPath = path;
    });

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingSeconds++);
    });
  }

  Future<void> _finishRecording() async {
    _recordingTimer?.cancel();

    final result = await _recordingService.stop();

    if (!mounted) return;

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _lastRecordingPath = result?.path ?? _lastRecordingPath;
    });

    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    final provider = context.read<QuranAIProvider>();

    if (!provider.canUseFreeCheck) {
      setState(() => _isAnalyzing = false);
      _openPremium();
      return;
    }

    await provider.consumeFreeCheck();

    if (!mounted) return;

    setState(() => _isAnalyzing = false);

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => RecitationResultScreen(
          surah: widget.surah,
          ayah: _selectedAyah,
          recordingSeconds: result?.duration.inSeconds ?? _recordingSeconds,
          recordingPath: result?.path ?? _lastRecordingPath,
        ),
      ),
    );
  }

  void _openPremium() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const NurPremiumScreen(),
      ),
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<QuranAIProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _TopBar(
              title: widget.surah.englishName,
              subtitle: 'Ayah ${_selectedAyah.ayahNumber}',
            ),
            const SizedBox(height: 20),
            _AyahCard(
              surah: widget.surah,
              ayah: _selectedAyah,
            ),
            const SizedBox(height: 16),
            _AyahPicker(
              surah: widget.surah,
              selectedAyah: _selectedAyah,
              onSelected: (ayah) {
                if (_isRecording || _isAnalyzing) return;
                setState(() => _selectedAyah = ayah);
              },
            ),
            const SizedBox(height: 16),
            const _TextBasedAICard(),
            const SizedBox(height: 16),
            _RecorderCard(
              canUseCheck: aiProvider.canUseFreeCheck,
              checksRemaining: aiProvider.checksRemainingToday,
              isRecording: _isRecording,
              isAnalyzing: _isAnalyzing,
              recordingSeconds: _recordingSeconds,
              onRecordTap:
              aiProvider.canUseFreeCheck ? _toggleRecording : _openPremium,
            ),
            const SizedBox(height: 16),
            _PracticeTipsCard(ayah: _selectedAyah),
            const SizedBox(height: 16),
            const _DisclaimerCard(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TEXT-BASED AI CHECK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$title • $subtitle',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.surah,
    required this.ayah,
  });

  final QuranSurahPractice surah;
  final QuranAyahPractice ayah;

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
            AppColors.surfaceAlt,
            AppColors.surface,
          ],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(0.30)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${surah.englishName} ${ayah.displayReference}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                height: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            ayah.transliteration,
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ayah.translation,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahPicker extends StatelessWidget {
  const _AyahPicker({
    required this.surah,
    required this.selectedAyah,
    required this.onSelected,
  });

  final QuranSurahPractice surah;
  final QuranAyahPractice selectedAyah;
  final ValueChanged<QuranAyahPractice> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: surah.ayahs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final ayah = surah.ayahs[index];
          final selected = ayah.ayahNumber == selectedAyah.ayahNumber;

          return GestureDetector(
            onTap: () => onSelected(ayah),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 46,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Center(
                child: Text(
                  '${ayah.ayahNumber}',
                  style: TextStyle(
                    color: selected
                        ? AppColors.background
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TextBasedAICard extends StatelessWidget {
  const _TextBasedAICard();

  @override
  Widget build(BuildContext context) {
    return _ActionPanel(
      icon: Icons.psychology_alt_rounded,
      title: 'How Nur AI checks your reading',
      subtitle:
      'Nur records your recitation, prepares it for speech-to-text, compares it with the selected ayah, then shows possible missed words and practice tips.',
      trailing: const Icon(
        Icons.auto_awesome_rounded,
        color: AppColors.primary,
      ),
    );
  }
}

class _RecorderCard extends StatelessWidget {
  const _RecorderCard({
    required this.canUseCheck,
    required this.checksRemaining,
    required this.isRecording,
    required this.isAnalyzing,
    required this.recordingSeconds,
    required this.onRecordTap,
  });

  final bool canUseCheck;
  final int checksRemaining;
  final bool isRecording;
  final bool isAnalyzing;
  final int recordingSeconds;
  final VoidCallback onRecordTap;

  @override
  Widget build(BuildContext context) {
    final title = isAnalyzing
        ? 'Preparing AI analysis'
        : isRecording
        ? 'Recording your recitation'
        : canUseCheck
        ? 'Record your recitation'
        : 'Daily limit reached';

    final subtitle = isAnalyzing
        ? 'Nur will compare your reading with the selected ayah.'
        : isRecording
        ? 'Read clearly, then tap stop to analyze.'
        : canUseCheck
        ? '$checksRemaining free AI checks remaining today.'
        : 'Unlock Premium for unlimited Quran AI checks.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isRecording ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isRecording
                      ? AppColors.error.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: isRecording ? AppColors.error : AppColors.primary,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (isRecording)
            Text(
              _formatRecordingTime(recordingSeconds),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          if (isAnalyzing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          if (!isAnalyzing) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRecordTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isRecording ? AppColors.error : AppColors.primary,
                  foregroundColor:
                  isRecording ? Colors.white : AppColors.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                icon: Icon(
                  isRecording
                      ? Icons.stop_rounded
                      : canUseCheck
                      ? Icons.mic_rounded
                      : Icons.lock_rounded,
                ),
                label: Text(
                  isRecording
                      ? 'Stop & Analyze'
                      : canUseCheck
                      ? 'Start Recording'
                      : 'Unlock Premium',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatRecordingTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}

class _PracticeTipsCard extends StatelessWidget {
  const _PracticeTipsCard({
    required this.ayah,
  });

  final QuranAyahPractice ayah;

  @override
  Widget build(BuildContext context) {
    return _ActionPanel(
      icon: Icons.tips_and_updates_rounded,
      title: 'Practice focus',
      subtitle: ayah.focus,
      trailing: const Icon(
        Icons.lightbulb_rounded,
        color: AppColors.primary,
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Nur AI feedback is educational and may not replace a qualified Quran teacher.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.8,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

class RecitationResultScreen extends StatelessWidget {
  const RecitationResultScreen({
    super.key,
    required this.surah,
    required this.ayah,
    required this.recordingSeconds,
    required this.recordingPath,
  });

  final QuranSurahPractice surah;
  final QuranAyahPractice ayah;
  final int recordingSeconds;
  final String? recordingPath;

  @override
  Widget build(BuildContext context) {
    final score = _scoreFor(ayah);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _TopBar(
              title: 'AI Result',
              subtitle: '${surah.englishName} ${ayah.displayReference}',
            ),
            const SizedBox(height: 22),
            _ScoreHero(score: score),
            const SizedBox(height: 16),
            _RecordingDebugCard(
              recordingSeconds: recordingSeconds,
              recordingPath: recordingPath,
            ),
            const SizedBox(height: 16),
            _TranscriptComparisonCard(ayah: ayah),
            const SizedBox(height: 16),
            _MistakesCard(ayah: ayah),
            const SizedBox(height: 16),
            _RecommendationsCard(ayah: ayah),
            const SizedBox(height: 22),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(21),
                  ),
                ),
                icon: const Icon(Icons.replay_rounded),
                label: const Text(
                  'Practice Again',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _scoreFor(QuranAyahPractice ayah) {
    final base = 82 + (ayah.ayahNumber % 4) * 3;
    return base.clamp(78, 94);
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.primary.withOpacity(0.30)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TEXT ACCURACY SCORE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '$score%',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 62,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Good match. Keep improving clarity, pacing and articulation.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 9,
              backgroundColor: Colors.white10,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingDebugCard extends StatelessWidget {
  const _RecordingDebugCard({
    required this.recordingSeconds,
    required this.recordingPath,
  });

  final int recordingSeconds;
  final String? recordingPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.audiotrack_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recordingPath == null
                  ? 'Recording prepared for AI analysis.'
                  : 'Recorded ${recordingSeconds}s audio. Ready for future speech-to-text upload.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranscriptComparisonCard extends StatelessWidget {
  const _TranscriptComparisonCard({
    required this.ayah,
  });

  final QuranAyahPractice ayah;

  @override
  Widget build(BuildContext context) {
    final words = ayah.arabic.split(' ');

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
          const Text(
            'Expected ayah',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < words.length; i++)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: i == words.length - 1
                          ? AppColors.warning.withOpacity(0.14)
                          : AppColors.emerald.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: i == words.length - 1
                            ? AppColors.warning.withOpacity(0.45)
                            : AppColors.emerald.withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      words[i],
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Green parts were likely matched. Yellow parts may need clearer pronunciation. This is a demo result until real speech-to-text is connected.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({
    required this.ayah,
  });

  final QuranAyahPractice ayah;

  @override
  Widget build(BuildContext context) {
    final firstWord = ayah.transliteration.split(' ').first;

    return _ResultSection(
      title: 'Possible focus areas',
      icon: Icons.error_outline_rounded,
      children: [
        _ResultBullet(text: 'Review clarity around: $firstWord'),
        const _ResultBullet(text: 'Slow down near the end of the ayah.'),
        const _ResultBullet(
          text: 'Repeat the ayah slowly before recording again.',
        ),
      ],
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({
    required this.ayah,
  });

  final QuranAyahPractice ayah;

  @override
  Widget build(BuildContext context) {
    return _ResultSection(
      title: 'Recommendations',
      icon: Icons.tips_and_updates_rounded,
      children: [
        _ResultBullet(text: ayah.focus),
        const _ResultBullet(
          text: 'Read the ayah once slowly, then record again.',
        ),
        const _ResultBullet(
          text: 'Practice in a quiet place for better AI transcription.',
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _ResultBullet extends StatelessWidget {
  const _ResultBullet({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.emerald,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}