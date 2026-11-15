import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/shop.dart';
import 'product_image.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({required this.shop, super.key});

  static const double imageSize = AppSpacing.shopCardImage;

  final Shop shop;

  /// Height the horizontal shop list needs for this text scale. Text grows but
  /// the artwork does not, so only the text-heavy rows need extra room. Derived
  /// from the same tokens the card paints with, so the list can never clip it.
  static double heightFor(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return imageSize +
        AppSpacing.sm +
        AppTypography.lineHeight(AppTypography.titleSmall, scaler) +
        AppSpacing.xxs +
        AppTypography.lineHeight(AppTypography.bodySmall, scaler) +
        AppSpacing.sm +
        kMinInteractiveDimension +
        AppSpacing.sm;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: AppSpacing.shopCardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(imageUrl: shop.imageUrl, size: imageSize),
          const SizedBox(height: AppSpacing.sm),
          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: context.palette.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            shop.distanceLabel,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.palette.textMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ShopAction(label: l10n?.exploreNow ?? 'Explore now'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShopAction(label: l10n?.orderOnline ?? 'Order online'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShopAction extends StatelessWidget {
  const _ShopAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: AppSpacing.shopCardButtonFontSize,
          color: context.palette.textMuted,
        ),
        foregroundColor: context.palette.textMuted,
        side: BorderSide(color: context.palette.border),
      ),
      child: Text(label),
    );
  }
}
