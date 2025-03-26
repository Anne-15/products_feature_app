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
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<String> categories = ['All', 'beauty', 'fragrances'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProviders>(context, listen: false).loadCategories();
      Provider.of<ProductProviders>(context, listen: false).fetchProducts();
    });

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final provider = Provider.of<ProductProviders>(context, listen: false);

    // Load more when 80% of the current content has been viewed
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchProducts();
      }
    }
  }

  void _onSearchChanged() {
    Provider.of<ProductProviders>(context, listen: false)
        .filterProducts(_searchController.text, _selectedCategory);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              setState(() => _selectedCategory = 'All');
              Provider.of<ProductProviders>(context, listen: false)
                  .clearFilters();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Consumer<ProductProviders>(
              builder: (context, provider, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name, brand or description...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => _onSearchChanged(),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(builder: (context, constraints) {
                      final chipCount = provider.categories.length;
                      const chipHeight = 40.0;
                      const neededHeight = chipHeight + 20;

                      return SizedBox(
                        height: neededHeight,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: chipCount,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = provider.categories[index];
                            return ChoiceChip(
                              label: Text(category.name),
                              selected: _selectedCategory == category.slug,
                              onSelected: (selected) {
                                setState(() => _selectedCategory = category.slug);
                                Provider.of<ProductProviders>(context, listen: false)
                                .filterProducts(
                                  _searchController.text, 
                                  category.slug
                                );
                              },
                            );
                          },
                        ),
                      );
                    })
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<ProductProviders>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading &&
              productProvider.displayedProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.displayedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filter',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _selectedCategory = 'All');
                      productProvider.clearFilters();
                    },
                    child: const Text('Clear all filters'),
                  ),
                ],
              ),
            );
          }

          if (productProvider.products.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              _searchController.clear();
              setState(() => _selectedCategory = 'All');
              Provider.of<ProductProviders>(context, listen: false)
                ..clearFilters()
                ..fetchProducts();
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: productProvider.displayedProducts.length +
                  (productProvider.hasMore ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                if (index >= productProvider.displayedProducts.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final product = productProvider.displayedProducts[index];
                return Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          child: Image.network(
                            product.thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                                Text(
                                  ' ${product.rating.toStringAsFixed(1)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
