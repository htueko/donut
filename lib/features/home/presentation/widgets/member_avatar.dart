import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({required this.imageUrl, this.size = 44, super.key});

  final String imageUrl;
  final double size;

  bool get _isAsset => imageUrl.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final image = _isAsset
        ? Image.asset(imageUrl, fit: BoxFit.cover)
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, _) => const ShimmerBox(radius: 50),
            errorWidget: (context, _, _) => const _AvatarFallback(),
          );
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.hairline,
      child: ClipOval(
        child: SizedBox(width: size, height: size, child: image),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Icon(Icons.person, color: AppColors.latte));
  }
}

class TierBadge extends StatelessWidget {
  const TierBadge({required this.tierLabel, required this.color, super.key});

  final String tierLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        tierLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
