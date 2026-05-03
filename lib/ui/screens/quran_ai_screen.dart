import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/quran_ai_provider.dart';
import 'nur_premium_screen.dart';

class QuranAIScreen extends StatelessWidget {
  const QuranAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranAIProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        )
            : ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            const _Header(),
            const SizedBox(height: 20),
            _HeroPracticeCard(provider: provider),
            const SizedBox(height: 18),
            _FreeLimitCard(provider: provider),
            const SizedBox(height: 18),
            const _HowItWorksCard(),
            const SizedBox(height: 18),
            const _SurahPracticeList(),
            const SizedBox(height: 18),
            const _PrivacyCard(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QURAN AI',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Improve recitation',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Practice Quran reading with voice feedback.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _HeroPracticeCard extends StatelessWidget {
  const _HeroPracticeCard({
    required this.provider,
  });

  final QuranAIProvider provider;

  @override
  Widget build(BuildContext context) {
    final canUse = provider.canUseFreeCheck;

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
        border: Border.all(color: AppColors.primary.withOpacity(0.32)),
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
            right: -48,
            top: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.09),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI RECITATION CHECK',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Read, record, improve',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 33,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose an ayah, listen to the correct recitation, record your voice and get feedback on mistakes.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canUse
                      ? () async {
                    await provider.consumeFreeCheck();
                    if (context.mounted) {
                      _showDemoResult(context);
                    }
                  }
                      : () => _openPremium(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                  icon: Icon(
                    canUse ? Icons.mic_rounded : Icons.lock_rounded,
                  ),
                  label: Text(
                    canUse ? 'Start AI Check' : 'Unlock Unlimited AI',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
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

  static void _showDemoResult(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.emerald,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Demo check used',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This is a placeholder. Next we will connect real recording, surah selection and AI pronunciation feedback.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FreeLimitCard extends StatelessWidget {
  const _FreeLimitCard({
    required this.provider,
  });

  final QuranAIProvider provider;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Free AI checks today',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${provider.checksRemainingToday}/${provider.freeDailyLimit} left',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: provider.freeLimitProgress,
              backgroundColor: Colors.white10,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Free users get 3 AI checks per day. Premium unlocks unlimited recitation practice.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          _StepTile(
            number: '1',
            title: 'Choose surah and ayah',
            subtitle: 'Start with short surahs or beginner-friendly ayahs.',
            icon: Icons.menu_book_rounded,
          ),
          _Divider(),
          _StepTile(
            number: '2',
            title: 'Listen to reference audio',
            subtitle: 'Hear the correct recitation before recording.',
            icon: Icons.volume_up_rounded,
          ),
          _Divider(),
          _StepTile(
            number: '3',
            title: 'Record your voice',
            subtitle: 'Read in one tap and send it for feedback.',
            icon: Icons.mic_rounded,
          ),
          _Divider(),
          _StepTile(
            number: '4',
            title: 'Get AI feedback',
            subtitle: 'See mistakes, highlights and recommendations.',
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String number;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahPracticeList extends StatelessWidget {
  const _SurahPracticeList();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _PracticeItem('Al-Fatiha', 'Beginner essential', '7 ayahs'),
      _PracticeItem('Al-Ikhlas', 'Short and powerful', '4 ayahs'),
      _PracticeItem('Al-Falaq', 'Daily protection', '5 ayahs'),
      _PracticeItem('An-Nas', 'Daily protection', '6 ayahs'),
    ];

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
            'Suggested practice',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            _PracticeTile(item: item),
            if (item != items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PracticeTile extends StatelessWidget {
  const _PracticeTile({
    required this.item,
  });

  final _PracticeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.46),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.menu_book_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.meta,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Voice privacy matters. Before real AI checks are enabled, users should clearly see how voice recordings are processed and whether they are stored.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}

class _PracticeItem {
  const _PracticeItem(this.title, this.subtitle, this.meta);

  final String title;
  final String subtitle;
  final String meta;
}