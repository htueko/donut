import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/motion/app_motion.dart';
import '../../../app/theme/app_palette.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/formatters/price_mmk_formatter.dart';
import '../../../core/result.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/product.dart';
import 'product_providers.dart';
import 'widgets/quantity_stepper.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  static const int minQuantity = 1;

  int _quantity = minQuantity;

  void _setQuantity(int value) {
    setState(() => _quantity = value < minQuantity ? minQuantity : value);
  }

  Future<void> _refresh() {
    return ref.read(catalogRepositoryProvider).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: productAsync.when(
          data: (product) => _ProductDetail(
            product: product,
            quantity: _quantity,
            onQuantityChanged: _setQuantity,
          ),
          loading: () => const _ProductDetailSkeleton(),
          error: (error, _) => ListView(
            children: [
              SizedBox(
                height: 480,
                child: ErrorRetryView(
                  message: _messageFor(context, error),
                  onRetry: () =>
                      ref.refresh(productByIdProvider(widget.productId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _messageFor(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context);
    return failureFromProductError(error) is NotFoundFailure
        ? l10n?.notFound ?? 'Not found'
        : l10n?.errorGeneric ?? 'Something went wrong';
  }
}

class _ProductDetail extends StatelessWidget {
  const _ProductDetail({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        // Main Product White Card Container
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: palette.border),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.productCode(product.code) ?? 'Code ${product.code}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                          fontWeight: AppTypography.captionWeight,
                        ),
                  ),
                  if (product.isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: palette.accent,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      child: Text(
                        l10n?.newBadge ?? 'New',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: palette.onAccent,
                              fontWeight: AppTypography.buttonWeight,
                              fontSize: 10,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: AppTypography.h1Weight,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                PriceMmkFormatter.format(
                  product.priceMmk,
                  locale: locale,
                  unit: l10n?.mmk ?? 'MMK',
                ),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: AppTypography.h2Weight,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Hero(
                  tag: 'product-${product.id}',
                  child: Image.network(
                    product.imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, _, _) => Image.asset(
                      'assets/seed/images/donut_coconut.png',
                      height: 200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: QuantityStepper(
                  quantity: quantity,
                  onChanged: onQuantityChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // What's this? Section with Green ? icon
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: palette.success,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: palette.onPrimary,
                    fontSize: 12,
                    fontWeight: AppTypography.buttonWeight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n?.whatsThis ?? 'What\'s this?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: AppTypography.h2Weight,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          product.description.isEmpty
              ? (l10n?.emptyGeneric ?? 'Nothing here yet')
              : product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
                height: 1.5,
              ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _AddToCartBar(product: product, quantity: quantity),
      ],
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final total = product.priceMmk * quantity;
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final formattedTotal = PriceMmkFormatter.format(
      total,
      locale: locale,
      unit: l10n?.mmk ?? 'MMK',
    );

    return Column(
      children: [
        Row(
          children: [
            Text(
              l10n?.total ?? 'Total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: motionScale(context, AppMotion.fast),
              child: Text(
                formattedTotal,
                key: ValueKey<int>(total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: palette.textPrimary,
                      fontWeight: AppTypography.h1Weight,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _showFeedback(context),
            style: FilledButton.styleFrom(
              backgroundColor: palette.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(
              l10n?.addToCart ?? 'Add to cart',
              style: AppTypography.button.copyWith(
                color: palette.onPrimary,
                fontWeight: AppTypography.buttonWeight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFeedback(BuildContext context) {
    final message =
        AppLocalizations.of(context)?.addedToCart(quantity) ??
        '$quantity added to cart';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProductDetailSkeleton extends StatelessWidget {
  const _ProductDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 320, radius: AppSpacing.radiusLg),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: 90, height: 12),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: 200, height: 20),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: 110, height: 16),
          SizedBox(height: AppSpacing.xl),
          ShimmerBox(width: 120, height: 16),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(height: 12),
          SizedBox(height: AppSpacing.xs),
          ShimmerBox(height: 12),
          SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              ShimmerBox(width: 80, height: 18),
              Spacer(),
              ShimmerBox(width: 140, height: 40, radius: 20),
            ],
          ),
        ],
      ),
    );
  }
}
