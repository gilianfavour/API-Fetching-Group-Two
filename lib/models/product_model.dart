class Product {

  // PRODUCT VARIABLES

  final int id;
  final String name;
  final String price;
  final String image;
  final String description;

  // CONSTRUCTOR

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  // CONVERT JSON TO PRODUCT OBJECT

  factory Product.fromJson(
      Map<String, dynamic> json) {

    return Product(

      id: json['id'],

      name:
          json['name'] ?? 'No Name',

      price:
          json['formatted_price']
              ?? 'No Price',

      image: _parseImage(json),

      description:
          json['description']
              ?? 'No Description',

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