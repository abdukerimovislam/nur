import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NurPremiumScreen extends StatelessWidget {
  const NurPremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _PremiumHeader(onClose: () => Navigator.of(context).pop()),
            const SizedBox(height: 24),
            const _HeroCard(),
            const SizedBox(height: 18),
            const _PlanSelector(),
            const SizedBox(height: 18),
            const _PremiumBenefitsCard(),
            const SizedBox(height: 18),
            const _TrustCard(),
            const SizedBox(height: 24),
            _SubscribeButton(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription setup will be connected later.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const _LegalText(),
          ],
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Nur Premium',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
          ),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
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
        border: Border.all(color: AppColors.primary),
        boxShadow: const [
          BoxShadow(
            color: AppColors.goldGlow,
            blurRadius: 42,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -50,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.09),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.28),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Build stronger prayer discipline',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unlock Quran AI, all widgets, prayer analytics and premium reminders designed for your daily spiritual growth.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  const _PlanSelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _PlanCard(
            title: 'Monthly',
            price: '\$3',
            period: '/month',
            selected: false,
            badge: null,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _PlanCard(
            title: 'Yearly',
            price: '\$25',
            period: '/year',
            selected: true,
            badge: 'Best value',
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.badge,
  });

  final String title;
  final String price;
  final String period;
  final bool selected;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.primary : AppColors.border;
    final backgroundColor = selected
        ? AppColors.primary.withOpacity(0.10)
        : AppColors.surface;

    return Container(
      height: 152,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 29),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  period,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumBenefitsCard extends StatelessWidget {
  const _PremiumBenefitsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          _BenefitTile(
            icon: Icons.graphic_eq_rounded,
            title: 'Unlimited Quran AI checks',
            subtitle: 'Practice recitation without daily limits.',
          ),
          _Divider(),
          _BenefitTile(
            icon: Icons.widgets_rounded,
            title: 'All Islamic widgets',
            subtitle: 'Prayer timer, ayah, dua and streak widgets.',
          ),
          _Divider(),
          _BenefitTile(
            icon: Icons.insights_rounded,
            title: 'Prayer analytics',
            subtitle: 'Track completion, streaks and weakest prayer.',
          ),
          _Divider(),
          _BenefitTile(
            icon: Icons.notifications_active_rounded,
            title: 'Premium reminders',
            subtitle: 'Motivational reminders to keep your streak alive.',
          ),
          _Divider(),
          _BenefitTile(
            icon: Icons.offline_bolt_rounded,
            title: 'Offline mode',
            subtitle: 'Keep essential content available offline.',
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.11),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 23,
            ),
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
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.emerald,
            size: 21,
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
    return const Divider(
      height: 1,
      color: AppColors.divider,
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard();

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
              'Your voice data for Quran AI should be handled privately and only used for recitation feedback. Full privacy controls will be shown before enabling AI checks.',
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

class _SubscribeButton extends StatelessWidget {
  const _SubscribeButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: const Text(
          'Continue with Yearly Plan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _LegalText extends StatelessWidget {
  const _LegalText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Subscription renews automatically unless cancelled at least 24 hours before the end of the current period. You can manage or cancel your subscription in your App Store account settings.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: 11.5,
        height: 1.45,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}