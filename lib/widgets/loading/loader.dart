import 'package:flutter/material.dart';

/// A reusable loading indicator (Circular Progress)
/// Follows the app's primary color (#000435 - Dark Blue)
class Loader extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const Loader({
    super.key,
    this.size = 40.0,
    this.color,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}