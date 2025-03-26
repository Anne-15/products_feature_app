import 'package:products_feature_app/components/logger.dart';
import 'package:products_feature_app/models/products.dart';
import 'package:products_feature_app/services/httpService.dart';

class ProductRepository {
  late HttpService httpService;

  ProductRepository(this.httpService);

  Future<List<Product>> getProducts() async {
    final response = await httpService.request(
      method: HttpMethod.get,
      url: 'https://dummyjson.com/products',
    );

    LoggerService.logger.i('Products response: $response');

    return (response as List<dynamic>).map((e) => Product.fromJson(e)).toList();
  }
}
