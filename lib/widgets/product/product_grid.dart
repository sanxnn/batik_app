import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../theme/app_spacing.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(product: products[index]),
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: AppSpacing.productMaxWidth,
          mainAxisExtent: AppSpacing.productHeight,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
      ),
    );
  }
}
