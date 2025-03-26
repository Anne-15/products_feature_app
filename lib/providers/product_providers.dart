import 'package:flutter/material.dart';
import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/repository/product_repository.dart';

class ProductProviders extends ChangeNotifier {
  final ProductRepository productRepository;

  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Product> get allProducts => products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _limit = 10;
  int _skip = 0;
  bool _hasMore = true;

  ProductProviders({required this.productRepository});

  Future<void> fetchProducts() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newProducts =
          await productRepository.getProducts(limit: _limit, skip: _skip);
      if (newProducts.isNotEmpty) {
        products.addAll(newProducts);
        _skip += _limit;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      LoggerService.logger.e("Error loading the products, $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterProducts(String query, String category) {
    LoggerService.logger
        .i('Filtering products: query="$query", category="$category"');
    filteredProducts = products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(query.toLowerCase());
      final matchesCategory = category == 'All' || product.category == category;

      LoggerService.logger.i(
          'Checking product: ${product.title}, matchesSearch: $matchesSearch, matchesCategory: $matchesCategory');

      return matchesSearch && matchesCategory;
    }).toList();

    LoggerService.logger.i('Filtered Products Count: ${filteredProducts.length}');

    notifyListeners();
  }
}
