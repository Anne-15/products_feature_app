import 'package:flutter/material.dart';
import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/repository/product_repository.dart';

class ProductProviders extends ChangeNotifier {
  final ProductRepository productRepository;

  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Product> get allProducts => products;
  String _currentSearchQuery = '';
  String _currentCategory = 'All';

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
    _currentSearchQuery = query;
    _currentCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<Product> results = List.from(products);

    // Apply search filter if query is not empty
    if (_currentSearchQuery.isNotEmpty) {
      results = results.where((product) {
        return product.title
                .toLowerCase()
                .contains(_currentSearchQuery.toLowerCase()) ||
            product.description
                .toLowerCase()
                .contains(_currentSearchQuery.toLowerCase()) ||
            product.brand
                .toLowerCase()
                .contains(_currentSearchQuery.toLowerCase());
      }).toList();
    }

    // Apply category filter if not 'All'
    if (_currentCategory != 'All') {
      results = results.where((product) {
        return product.category.toLowerCase() == _currentCategory.toLowerCase();
      }).toList();
    }

    filteredProducts = results;
    notifyListeners();
  }

  void clearFilters() {
    _currentSearchQuery = '';
    _currentCategory = 'All';
    filteredProducts = List.from(products);
    notifyListeners();
  }
}
