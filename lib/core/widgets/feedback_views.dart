import 'package:flutter/material.dart';

import '../../app/motion/app_motion.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/formatters/price_mmk_formatter.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../l10n/app_localizations.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnimatedSize(
      duration: motionScale(context, AppMotion.base),
      curve: AppMotion.standard,
      child: Container(
        width: double.infinity,
        color: palette.textPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 18, color: palette.background),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: palette.background),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSpacing.errorIconSize,
            color: context.palette.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
          ),
        ],
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.message,
    this.icon = Icons.circle_outlined,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppSpacing.emptyIconSize,
            color: context.palette.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class PriceText extends StatelessWidget {
  const PriceText({required this.amount, super.key});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Text(
      PriceMmkFormatter.format(
        amount,
        locale: Localizations.localeOf(context).toString(),
        unit: AppLocalizations.of(context)?.mmk ?? 'MMK',
      ),
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: context.palette.primary),
    );
  }
}

class ProductTileSkeleton extends StatelessWidget {
  const ProductTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return SizedBox(
      width: AppSpacing.tileWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(
            height: AppSpacing.tileImage,
            radius: AppSpacing.radiusLg,
          ),
          const SizedBox(height: AppSpacing.sm),
          ShimmerBox(
            height: AppSpacing.skeletonLine * scale,
            width: AppSpacing.skeletonLineWidth,
          ),
          const SizedBox(height: AppSpacing.xs),
          ShimmerBox(
            height: AppSpacing.skeletonLineSmall * scale,
            width: AppSpacing.skeletonLineSmallWidth,
          ),
        ],
      ),
    );
  }
}
