import 'product_model.dart';

class ProductResponse {

  // LIST OF PRODUCTS

  final List<Product> products;

  // PAGINATION VARIABLES

  final int currentPage;
  final int lastPage;
  final int total;

  // CONSTRUCTOR

  ProductResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  // CONVERT JSON TO RESPONSE OBJECT

  factory ProductResponse.fromJson(
      Map<String, dynamic> json) {

    // GET PRODUCTS ARRAY

    List productsJson =
        json['data'];

    // CONVERT PRODUCTS ARRAY
    // INTO PRODUCT OBJECTS

    List<Product> products =
        productsJson.map((item) {

      return Product.fromJson(item);

    }).toList();

    // RETURN RESPONSE OBJECT

    return ProductResponse(

      products: products,

      currentPage:
          json['meta']['current_page'],

      lastPage:
          json['meta']['last_page'],

      total:
          json['meta']['total'],

    );
  }
}