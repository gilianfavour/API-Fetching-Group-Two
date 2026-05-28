import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Reusable Shimmer Effect Widget
/// Used to show skeleton loading states across the app
class AppShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Duration period;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: period,
      child: child,
    );
  }
}