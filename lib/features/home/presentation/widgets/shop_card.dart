import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/shop.dart';
import 'product_image.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({required this.shop, super.key});

  static const double imageSize = 110;
  static const double _baseHeight = 204;

  final Shop shop;

  /// Height the horizontal shop list needs for this text scale. Text grows but
  /// the artwork does not, so only the text-heavy rows need extra room.
  static double heightFor(BuildContext context) {
    return _baseHeight * MediaQuery.textScalerOf(context).scale(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(imageUrl: shop.imageUrl, size: imageSize),
          const SizedBox(height: AppSpacing.sm),
          Text(
            shop.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            shop.distanceLabel,
            style: const TextStyle(color: AppColors.latte, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: Text(l10n?.exploreNow ?? 'Explore now'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    textStyle: const TextStyle(fontSize: 11),
                  ),
                  child: Text(l10n?.orderOnline ?? 'Order online'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
