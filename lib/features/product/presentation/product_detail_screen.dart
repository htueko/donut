import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/motion/app_motion.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/formatters/price_mmk_formatter.dart';
import '../../../core/result.dart';
import '../../../core/widgets/feedback_views.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalog/data/catalog_providers.dart';
import '../../catalog/domain/product.dart';
import '../../home/presentation/widgets/product_image.dart';
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Hero(
          tag: 'product-${product.id}',
          child: ProductImage(
            imageUrl: product.imageUrl,
            size: 320,
            isNew: product.isNew,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Code ${product.code}',
          style: const TextStyle(color: AppColors.cocoa, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        PriceText(amount: product.priceMmk),
        if (product.discountPercent != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${product.discountPercent}% off',
            style: const TextStyle(
              color: AppColors.seed,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          AppLocalizations.of(context)?.whatsThis ?? 'What\'s this?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          product.description.isEmpty
              ? (AppLocalizations.of(context)?.emptyGeneric ?? 'Nothing here yet')
              : product.description,
          style: const TextStyle(
            color: AppColors.cocoa,
            height: 1.4,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Text(
              AppLocalizations.of(context)?.quantity ?? 'Quantity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            QuantityStepper(
              quantity: quantity,
              onChanged: onQuantityChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
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
    return Column(
      children: [
        Row(
          children: [
            Text(
              AppLocalizations.of(context)?.total ?? 'Total',
              style: const TextStyle(color: AppColors.cocoa, fontSize: 13),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: motionScale(context, AppMotion.fast),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                PriceMmkFormatter.format(total),
                key: ValueKey<int>(total),
                style: const TextStyle(
                  color: AppColors.chocolate,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
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
            child: Text(
              AppLocalizations.of(context)?.addToCart ?? 'Add to cart',
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
