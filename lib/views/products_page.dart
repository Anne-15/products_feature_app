import 'package:flutter/material.dart';
import 'package:products_feature_app/providers/product_providers.dart';
import 'package:provider/provider.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<ProductProviders>(context, listen: false).fetchProducts();
    });

    _scrollController = ScrollController();
    _scrollController.addListener(onScroll);
  }

  void onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<ProductProviders>(context, listen: false).fetchProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProductProviders>(
        builder: (context, productProvider, child) {
          if (productProvider.products.isEmpty && productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            itemCount: productProvider.products.length +
                (productProvider.isLoading ? 1 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              if (index == productProvider.products.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final product = productProvider.products[index];
              return Card(
                elevation: 3,
                child: Column(
                  children: [
                    Expanded(
                      child:
                          Image.network(product.thumbnail, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(product.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text("\$${product.price}",
                        style: TextStyle(color: Colors.green, fontSize: 16)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
