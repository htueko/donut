import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../l10n/app_localizations.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.imageUrl,
    required this.size,
    this.isNew = false,
    super.key,
  });

  final String imageUrl;
  final double size;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final image = imageUrl.startsWith('assets/')
        ? Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) => ShimmerBox(
              width: size,
              height: size,
              radius: AppSpacing.radiusMd,
            ),
            errorWidget: (context, _, _) =>
                ColoredBox(color: palette.shimmerBase),
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            if (isNew)
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _NewBadge(
                  label: AppLocalizations.of(context)?.newBadge ?? 'NEW',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.badgeHorizontalPadding,
        vertical: AppSpacing.badgeVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: palette.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: palette.onPrimary,
          fontWeight: AppTypography.buttonWeight,
        ),
      ),
    );
  }
}
