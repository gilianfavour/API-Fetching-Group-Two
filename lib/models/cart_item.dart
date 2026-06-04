import 'product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get unitPrice {
    // Remove all non-digit and non-dot characters (e.g., "UGX 80,000" -> "80000")
    final cleaned = product.price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get total {
    return unitPrice * quantity;
  }
}
