import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/formatters/percent_formatter.dart';
import '../../../../core/formatters/price_mmk_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/product.dart';
import 'product_image.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({required this.product, super.key});

  final Product product;

  /// Artwork is a fixed size; the text under it grows with the user's text
  /// scale, so the row has to grow with it or the tiles clip. Heights come from
  /// the same roles the tile renders with, and the price row reserves room for
  /// the discount badge so every tile in a strip stays the same height.
  static double heightFor(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final priceLine = max(
      AppTypography.lineHeight(AppTypography.bodySmall, scaler),
      AppTypography.lineHeight(AppTypography.caption, scaler) +
          AppSpacing.badgeVerticalPadding * 2,
    );
    return AppSpacing.tileImage +
        AppSpacing.sm +
        AppTypography.lineHeight(AppTypography.titleSmall, scaler) +
        AppSpacing.xxs +
        priceLine;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final price = PriceMmkFormatter.format(
      product.priceMmk,
      locale: locale,
      unit: l10n?.mmk ?? 'MMK',
    );
    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: SizedBox(
        width: AppSpacing.tileWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-${product.id}',
              child: ProductImage(
                imageUrl: product.imageUrl,
                size: AppSpacing.tileImage,
                isNew: product.isNew,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: context.palette.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                Flexible(
                  child: Text(
                    price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.palette.textSecondary),
                  ),
                ),
                if (product.discountPercent != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.badgeHorizontalPadding,
                      vertical: AppSpacing.badgeVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: context.palette.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      '-${PercentFormatter.format(product.discountPercent!, locale: locale)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: context.palette.primary,
                        fontWeight: AppTypography.buttonWeight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
