import 'package:flutter/material.dart';
import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/repository/product_repository.dart';

class ProductProviders extends ChangeNotifier {
  final ProductRepository productRepository;

  List<Product> products = [];
  List<Product> get allProducts => products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _page = 1;
  final int _limit = 10;

  ProductProviders({required this.productRepository});

  Future<void> fetchProducts() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newProducts = await productRepository.getProducts();
      products.addAll(newProducts);
    } catch (e) {
      LoggerService.logger.e("Error loading the products, $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
