import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/feedback_views.dart';
import '../../../catalog/domain/product.dart';
import 'product_tile.dart';

class ProductRow extends StatelessWidget {
  const ProductRow({
    required this.title,
    required this.products,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final List<Product> products;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SectionHeader(title: title),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSpacing.tileImage + 48,
          child: products.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(color: AppColors.latte),
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (context, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      ProductTile(product: products[index]),
                ),
        ),
      ],
    );
  }
}
