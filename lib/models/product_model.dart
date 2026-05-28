class Product {

  // PRODUCT VARIABLES

  final int id;
  final String name;
  final String price;
  final String image;
  final String description;
  final String? brand;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final String? sku;

  // CONSTRUCTOR

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockQuantity = 10,
    this.sku,
  });

  bool get isLimited => stockQuantity <= 3;

  // CONVERT JSON TO PRODUCT OBJECT

  factory Product.fromJson(
      Map<String, dynamic> json) {

    return Product(

      id: json['id'] ?? 0,

      name:
          json['name'] ?? 'No Name',

      price:
          json['formatted_price'] ?? json['price']?.toString() ?? 'No Price',

      image: _parseImage(json),

      description:
          json['description']
              ?? 'No Description',

      brand: (json['brand'] as Map?)?['name'] ?? (json['category'] as Map?)?['name'],
      rating: ((json['average_rating'] ?? json['rating'] ?? 0) as num).toDouble(),
      reviewCount: json['review_count'] ?? json['reviews_count'] ?? 0,
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '') ?? 10,
      sku: json['sku'],
    );
  }

  // HELPER: Parse image from API response
  // The API returns 'main_image' as a full URL (Cloudinary),
  // or 'image' which may be a relative path.

  static String _parseImage(
      Map<String, dynamic> json) {
    // Try 'main_image' first (full URL)
    final mainImage =
        json['main_image']?.toString();

    if (mainImage != null &&
        mainImage.isNotEmpty) {
      return mainImage;
    }

    // Fallback to 'image'
    final image =
        json['image']?.toString();

    if (image != null &&
        image.isNotEmpty) {
      // If it's already a full URL, use as-is
      if (image.startsWith('http')) {
        return image;
      }
      // Otherwise prepend base URL
      return 'https://admin.rasmuspharmaceuticals.com$image';
    }

    return '';
  }
}