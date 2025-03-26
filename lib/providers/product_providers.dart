import 'package:flutter/material.dart';
import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/repository/product_repository.dart';

class ProductProviders extends ChangeNotifier {
  final ProductRepository productRepository;

  List<Product> products = [];
  List<Product> filteredProducts = [];

  List<Product> get allProducts => products;
  List<Product> get displayedProducts => filteredProducts;

  List<ProductCategory> _categories = [];
  List<ProductCategory> get categories => _categories;

  String _currentSearchQuery = '';
  String? _selectedCategorySlug;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _limit = 30;
  int _skip = 0;
  bool hasMore = true;
  int _totalProducts = 194;

  ProductProviders({required this.productRepository});

  Future<void> loadCategories() async {
    try {
      final fetchedCategories = await productRepository.getAllCategories();
      _categories = [
        ProductCategory(
            slug: 'all', name: 'All', url: ''),
        ...fetchedCategories,
      ];
      notifyListeners();
    } catch (e) {
      LoggerService.logger.e("Error loading categories: $e");
      _categories = [ProductCategory(slug: 'all', name: 'All', url: '')];
      notifyListeners();
    }
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (_isLoading || (!hasMore && !reset)) return;

    _isLoading = true;
    if (reset) {
      _skip = 0;
      hasMore = true;
      products.clear();
      notifyListeners();
    }

    try {
      final newProducts = await productRepository.getProducts(
        limit: _limit,
        skip: _skip,
      );

      if (newProducts.isNotEmpty) {
        products.addAll(newProducts);
        _skip += newProducts.length;
        hasMore = products.length < _totalProducts;
        _applyFilters(); // Apply current filters to new products
      } else {
        hasMore = false;
      }
    } catch (e) {
      LoggerService.logger.e("Error loading the products, $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterProducts(String query, String categorySlug) {
    _currentSearchQuery = query;
    _selectedCategorySlug = categorySlug;
    _applyFilters();
  }

  void _applyFilters() {
    // Start with all products
    List<Product> results = List.from(products);

    // Apply search filter
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

    // Apply category filter if not 'all'
    if (_selectedCategorySlug != null && _selectedCategorySlug != 'all') {
      results = results.where((product) {
        return product.category.toLowerCase() ==
            _selectedCategorySlug!.toLowerCase();
      }).toList();
    }

    // Update filtered products
    filteredProducts = results;
    notifyListeners();
  }

  void clearFilters() {
    _currentSearchQuery = '';
    _selectedCategorySlug = 'all';
    filteredProducts = List.from(products);
    notifyListeners();
  }
}
