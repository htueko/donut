import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/shimmer_box.dart';

class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    required this.imageUrl,
    this.size = AppSpacing.avatarSize,
    super.key,
  });

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
            placeholder: (context, _) =>
                ShimmerBox(width: size, height: size, radius: size / 2),
            errorWidget: (context, _, _) => const _AvatarFallback(),
          );
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: context.palette.border,
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
    return Center(child: Icon(Icons.person, color: context.palette.textMuted));
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
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        tierLabel,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: AppTypography.captionWeight),
      ),
    );
  }
}
