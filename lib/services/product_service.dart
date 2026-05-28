import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/product_response.dart';

class ProductService {

  // BASE URL

  static const String baseUrl =
      'https://admin.rasmuspharmaceuticals.com/api/v1/products';

  // =========================================
  // FETCH ALL PRODUCTS
  // =========================================

  Future<ProductResponse> fetchProducts({
    int page = 1,
  }) async {

    try {

      final url =
          Uri.parse('$baseUrl?page=$page');

      final response =
          await http.get(url);

      if (response.statusCode == 200) {
         
         print(response.body);

        final data =
            jsonDecode(response.body);

        return ProductResponse.fromJson(
          data,
        );

      } else {

        throw Exception(
          'Failed to load products',
        );
      }

    } catch (e) {

      throw Exception(
        'Error fetching products: $e',
      );
    }
  }

  // =========================================
  // FETCH SINGLE PRODUCT DETAILS
  // =========================================

  Future<Product> fetchProductDetails(
    int productId,
  ) async {

    try {

      // PRODUCT DETAILS URL

      final url = Uri.parse(
        '$baseUrl/$productId',
      );

      // SEND REQUEST

      final response =
          await http.get(url);

      // CHECK RESPONSE

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        // SOME APIs RETURN:
        // { data: {...} }

        return Product.fromJson(
          data['data'],
        );

      } else {

        throw Exception(
          'Failed to load product details',
        );
      }

    } catch (e) {

      throw Exception(
        'Error fetching product details: $e',
      );
    }
  }
}