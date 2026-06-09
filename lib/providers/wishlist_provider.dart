import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  WishlistProvider() {
    _loadFromPrefs();
  }

  bool contains(int productId) {
    return _items.any((p) => p.id == productId);
  }

  void toggleWishlist(Product product) {
    if (contains(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.removeWhere((p) => p.id == productId);
    _saveToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('wishlist_items');
      if (list != null) {
        _items.clear();
        for (var item in list) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is Map<String, dynamic>) {
              _items.add(Product.fromJson(decoded));
            }
          } catch (e) {
            debugPrint('Error decoding wishlist item: $e');
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList('wishlist_items', list);
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }
}
