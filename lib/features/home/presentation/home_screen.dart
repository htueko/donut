import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../../l10n/app_localizations.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/catalog_data.dart';
import '../../catalog/domain/catalog_enums.dart';
import '../../catalog/domain/member.dart';
import '../../catalog/domain/shop.dart';
import '../../catalog/domain/tier_progress.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/member_avatar.dart';
import 'widgets/product_row.dart';
import 'widgets/product_tile.dart';
import 'widgets/shop_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogDataProvider);
    final online = ref.watch(onlineStatusProvider).valueOrNull ?? true;
    return Scaffold(
      body: Column(
        children: [
          if (!online)
            OfflineBanner(
              message:
                  AppLocalizations.of(context)?.offline ?? 'You\'re offline',
            ),
          Expanded(
            child: catalog.when(
              data: (data) => _HomeContent(data: data),
              loading: () => const _HomeSkeleton(),
              error: (error, _) => ErrorRetryView(
                message:
                    AppLocalizations.of(context)?.errorGeneric ??
                    'Something went wrong',
                onRetry: () => ref.refresh(catalogDataProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.data});

  final CatalogData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final member = data.member;
    return RefreshIndicator(
      onRefresh: () => ref.read(catalogRepositoryProvider).refresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        children: [
          if (member != null) _MemberHeader(member: member),
          const SizedBox(height: AppSpacing.md),
          if (data.banners.isNotEmpty) BannerCarousel(banners: data.banners),
          const SizedBox(height: AppSpacing.lg),
          ProductRow(
            title: l10n?.seasonalSpecials ?? 'Seasonal specials',
            products: data.productsInSection(CatalogSection.seasonal),
            emptyMessage: l10n?.emptyGeneric ?? 'Nothing here yet',
          ),
          const SizedBox(height: AppSpacing.lg),
          ProductRow(
            title: l10n?.popular ?? 'Popular',
            products: data.productsInSection(CatalogSection.popular),
            emptyMessage: l10n?.emptyGeneric ?? 'Nothing here yet',
          ),
          const SizedBox(height: AppSpacing.lg),
          ProductRow(
            title: l10n?.orderAgain ?? 'Order again',
            products: data.productsInSection(CatalogSection.orderAgain),
            emptyMessage: l10n?.emptyGeneric ?? 'Nothing here yet',
          ),
          const SizedBox(height: AppSpacing.lg),
          _NearbyShops(shops: data.shops),
        ],
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final progress = TierProgress(member.tier, member.points);
    final points = NumberFormat.decimalPattern('en').format(member.points);
    final toNext = NumberFormat.decimalPattern('en')
        .format(progress.pointsToNext);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          MemberAvatar(imageUrl: member.photoUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    TierBadge(
                      tierLabel: member.tier.displayName,
                      color: AppColors.tierColor(member.tier.name),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '$points pts · $toNext to '
                        '${progress.nextTier?.displayName ?? 'max'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.cocoa,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Badge(
            label: Text('${member.notificationsCount}'),
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyShops extends StatelessWidget {
  const _NearbyShops({required this.shops});

  final List<Shop> shops;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SectionHeader(
            title:
                l10n?.nearbyShopsTitle(shops.length) ??
                'There are ${shops.length} J\'Donut shops near you',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: ShopCard.heightFor(context),
          child: shops.isEmpty
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      l10n?.emptyGeneric ?? 'Nothing here yet',
                      style: const TextStyle(color: AppColors.latte),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: shops.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) => ShopCard(shop: shops[index]),
                ),
        ),
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 44, height: 44, radius: 22),
              SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 90, height: 10),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(height: 140, radius: 16),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: 160, height: 16),
          SizedBox(height: AppSpacing.md),
          _SkeletonStrip(),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: 120, height: 16),
          SizedBox(height: AppSpacing.md),
          _SkeletonStrip(),
        ],
      ),
    );
  }
}

class _SkeletonStrip extends StatelessWidget {
  const _SkeletonStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ProductTile.heightFor(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 3,
        separatorBuilder: (context, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, _) => const ProductTileSkeleton(),
      ),
    );
  }
}
