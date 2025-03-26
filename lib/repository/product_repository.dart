import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/services/httpService.dart';

class ProductRepository {
  late HttpService httpService;

  ProductRepository(this.httpService);

  Future<List<Product>> getProducts({limit, skip}) async {
    final response = await httpService.request(
      method: HttpMethod.get,
      url: 'https://dummyjson.com/products?limit=$limit&skip=$skip',
    );

    if (response['products'] == null) {
      throw Exception('Invalid API response');
    }

    final products = response['products'] as List;
    LoggerService.logger.i('Fetched ${products.length} products');

    return (response['products'] as List<dynamic>)
        .map((e) => Product.fromJson(e))
        .toList();
  }

  Future<List<ProductCategory>> getAllCategories() async {
    try {
      final response = await httpService.request(
        method: HttpMethod.get,
        url: 'https://dummyjson.com/products/categories',
      );

      LoggerService.logger
          .i('Categories response type: ${response.runtimeType}');

      if (response is List) {
        return response.map((item) {
          if (item is String) {
            return ProductCategory(
              slug: item.toLowerCase().replaceAll(' ', '-'),
              name: item
                  .split('-')
                  .map((s) => s[0].toUpperCase() + s.substring(1))
                  .join(' '),
              url: 'https://dummyjson.com/products/category/$item',
            );
          }
          return ProductCategory.fromJson(item as Map<String, dynamic>);
        }).toList();
      }

      throw Exception('Unexpected response format: $response');
    } catch (e) {
      LoggerService.logger.e("Error fetching categories: $e");
      return [];
    }
  }
}
