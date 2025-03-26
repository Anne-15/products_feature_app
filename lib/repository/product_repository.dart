import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/services/httpService.dart';

class ProductRepository {
  late HttpService httpService;

  ProductRepository(this.httpService);

  Future<List<Product>> getProducts({int limit = 10, int skip = 0}) async {
    final response = await httpService.request(
      method: HttpMethod.get,
      url: 'https://dummyjson.com/products?limit=$limit&skip=$skip',
    );

    LoggerService.logger.i(response['products']);

    return (response['products'] as List<dynamic>)
        .map((e) => Product.fromJson(e))
        .toList();
  }
}
