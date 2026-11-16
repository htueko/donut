import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/motion/app_motion.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/decimal_formatter.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/catalog_data.dart';
import '../../catalog/domain/catalog_enums.dart';
import '../../catalog/domain/challenge.dart';
import '../../catalog/domain/member.dart';
import '../../catalog/domain/tier_progress.dart';
import '../../catalog/presentation/tier_label.dart';
import '../../home/presentation/widgets/member_avatar.dart';
import 'widgets/challenge_card.dart';
import 'widgets/points_ring.dart';
import 'widgets/reward_tabs.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogDataProvider);
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: catalog.when(
            data: (data) => _RewardsContent(data: data),
            loading: () => const _RewardsSkeleton(),
            error: (error, _) => ErrorRetryView(
              message:
                  AppLocalizations.of(context)?.errorGeneric ??
                  'Something went wrong',
              onRetry: () => ref.refresh(catalogDataProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardsContent extends StatelessWidget {
  const _RewardsContent({required this.data});

  final CatalogData data;

  @override
  Widget build(BuildContext context) {
    final member = data.member;
    final palette = context.palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'J\' Donuts Rewards',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: AppTypography.h1Weight,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: palette.accent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)?.rewardsTitle ?? 'Rewards',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: palette.onAccent,
                          fontWeight: AppTypography.buttonWeight,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: palette.onAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: palette.accent,
                          fontSize: 11,
                          fontWeight: AppTypography.buttonWeight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (member != null) _PointsCard(member: member),
        const SizedBox(height: AppSpacing.xl),
        _ChallengeList(
          challenges: data.challenges,
          header:
              AppLocalizations.of(context)?.eatMoreEarnMore ??
              'Eat more earn more',
        ),
      ],
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final progress = TierProgress(member.tier, member.points);
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PointsRing(
                progress: progress.fractionIntoTier,
                total: member.points,
                centerLabel: l10n?.points ?? 'points',
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MemberAvatar(
                          imageUrl: member.photoUrl,
                          size: AppSpacing.avatarSmall,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            member.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: palette.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TierBadge(
                      tierLabel: member.tier.localizedLabel(l10n),
                      color: AppColors.tierColor(member.tier.name),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _pointsToNextLabel(context, progress),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: palette.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TierLadder(
            tiers: const [Tier.silver, Tier.gold, Tier.platinum],
            currentIndex: _ladderIndex(member.tier),
            fractionIntoTier: progress.fractionIntoTier,
          ),
        ],
      ),
    );
  }

  int _ladderIndex(Tier tier) {
    return switch (tier) {
      Tier.bronze => 0,
      Tier.silver => 0,
      Tier.gold => 1,
      Tier.platinum => 2,
    };
  }

  String _pointsToNextLabel(BuildContext context, TierProgress progress) {
    final l10n = AppLocalizations.of(context);
    final points = DecimalFormatter.format(
      progress.pointsToNext,
      locale: Localizations.localeOf(context).toString(),
    );
    final next = progress.nextTier?.localizedLabel(l10n) ?? l10n?.max ?? 'max';
    return l10n?.pointsToNextTier(points, next) ?? '$points points to $next';
  }
}

class _ChallengeList extends StatelessWidget {
  const _ChallengeList({required this.challenges, required this.header});

  final List<Challenge> challenges;
  final String header;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RewardTabs(
      labels: [
        l10n?.eatMoreEarnMore ?? 'Eat more earn more',
        l10n?.giftTab ?? 'Gift',
      ],
      builders: [
        (context) => _ChallengeColumn(
          challenges: challenges,
          header: header,
          emptyMessage: l10n?.emptyGeneric ?? 'Nothing here yet',
          earnLabel: l10n?.earn ?? 'Earn',
        ),
        (context) =>
            GiftPanel(message: l10n?.emptyGeneric ?? 'Nothing here yet'),
      ],
    );
  }
}

class _ChallengeColumn extends StatelessWidget {
  const _ChallengeColumn({
    required this.challenges,
    required this.header,
    required this.emptyMessage,
    required this.earnLabel,
  });

  final List<Challenge> challenges;
  final String header;
  final String emptyMessage;
  final String earnLabel;

  @override
  Widget build(BuildContext context) {
    if (challenges.isEmpty) {
      return EmptyStateView(message: emptyMessage, icon: Icons.emoji_events);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: header),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < challenges.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _StaggeredCard(
            index: i,
            child: ChallengeCard(
              challenge: challenges[i],
              rewardLabel: earnLabel,
            ),
          ),
        ],
      ],
    );
  }
}

class _StaggeredCard extends StatefulWidget {
  const _StaggeredCard({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final Animation<double> _enter = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.emphasized,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    final delay = AppMotion.fast * widget.index;
    Future<void>.delayed(delay, () {
      if (mounted) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final t = MediaQuery.disableAnimationsOf(context) ? 1.0 : _enter.value;
        return Opacity(
          opacity: 0.15 + 0.85 * t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 24),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _RewardsSkeleton extends StatelessWidget {
  const _RewardsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 140, height: 24),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(height: 210, radius: AppSpacing.radiusLg),
          SizedBox(height: AppSpacing.xl),
          ShimmerBox(height: 44, radius: AppSpacing.radiusPill),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(height: 88, radius: AppSpacing.radiusLg),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(height: 88, radius: AppSpacing.radiusLg),
        ],
      ),
    );
  }
}
