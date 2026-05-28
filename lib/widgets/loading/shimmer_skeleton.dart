import 'package:flutter/material.dart';
import 'shimmer.dart';

/// Contains all shimmer skeleton widgets for consistent loading states

/// Single Product Card Shimmer (Used in Grid and Horizontal Lists)
class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            
            // Product Name Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 18,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            // Price Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 18,
                width: 90,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Grid Shimmer - For Product Catalog Page (3 columns)
class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.72,           // Adjusted for better look
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 9,                       // Show 9 placeholders (3x3)
      itemBuilder: (context, index) => const ProductCardShimmer(),
    );
  }
}

/// Horizontal List Shimmer - For Home Page featured products
class HorizontalProductShimmer extends StatelessWidget {
  const HorizontalProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: 210,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 150,
                child: ProductCardShimmer(),
              ),
            );
          },
        ),
      ),
    );
  }
}