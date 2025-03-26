import 'package:flutter/material.dart';
import 'package:products_feature_app/providers/product_providers.dart';
import 'package:products_feature_app/repository/product_repository.dart';
import 'package:products_feature_app/services/httpService.dart';
import 'package:products_feature_app/views/products_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ProductProviders(
        productRepository: ProductRepository(HttpService()),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Features App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ProductsPage(),
    );
  }
}
