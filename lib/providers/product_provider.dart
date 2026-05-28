import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {

  // SERVICE

  final ProductService _productService =
      ProductService();

  // =====================================
  // STATES
  // =====================================

  List<Product> _products = [];

  Product? _selectedProduct;

  bool _isLoading = false;

  String? _error;

  int _currentPage = 1;

  int _lastPage = 1;

  // =====================================
  // GETTERS
  // =====================================

  List<Product> get products =>
      _products;

  Product? get selectedProduct =>
      _selectedProduct;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  int get currentPage =>
      _currentPage;

  int get lastPage =>
      _lastPage;

  // =====================================
  // FETCH PRODUCTS
  // =====================================

  Future<void> fetchProducts({
    int page = 1,
  }) async {

    try {

      _isLoading = true;

      _error = null;

      notifyListeners();

      final response =
          await _productService
              .fetchProducts(
        page: page,
      );

      _products =
          response.products;

      _currentPage =
          response.currentPage;

      _lastPage =
          response.lastPage;

    } catch (e) {

      _error = e.toString();

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================
  // FETCH SINGLE PRODUCT
  // =====================================

  Future<void> fetchProductDetails(
    int productId,
  ) async {

    try {

      _isLoading = true;

      _error = null;

      notifyListeners();

      final response =
          await _productService
              .fetchProductDetails(
        productId,
      );

      _selectedProduct =
          response;

    } catch (e) {

      _error = e.toString();

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  // =====================================
  // PAGINATION
  // =====================================

  Future<void> nextPage() async {

    if (_currentPage < _lastPage) {

      _currentPage++;

      await fetchProducts(
        page: _currentPage,
      );
    }
  }

  Future<void> previousPage() async {

    if (_currentPage > 1) {

      _currentPage--;

      await fetchProducts(
        page: _currentPage,
      );
    }
  }
}