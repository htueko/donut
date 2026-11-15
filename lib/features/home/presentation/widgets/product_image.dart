import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';

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
    final image = imageUrl.startsWith('assets/')
        ? Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) =>
                const ShimmerBox(radius: AppSpacing.radiusMd),
            errorWidget: (context, _, _) =>
                const ColoredBox(color: AppColors.shimmerBase),
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
              const Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: _NewBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.seed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
