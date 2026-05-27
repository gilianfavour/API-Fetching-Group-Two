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

      image:
          json['image'] ?? '',

      description:
          json['description']
              ?? 'No Description',

    );
  }
}