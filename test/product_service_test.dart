import 'package:batik_app/services/product_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'product service sends page and filters, parses nested pagination',
    () async {
      late RequestOptions request;
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': {
                    'current_page': 2,
                    'last_page': 3,
                    'data': [
                      {
                        'id': 12,
                        'name': 'Batik Melati',
                        'slug': 'batik-melati',
                        'variants': [
                          {
                            'id': 41,
                            'name': '2 Meter',
                            'sku': 'BT-2M',
                            'price': 250000,
                            'stock': 5,
                          },
                        ],
                      },
                    ],
                  },
                },
              ),
            );
          },
        ),
      );
      final result = await ProductService(dio: dio)
          .getProducts(page: 2, categoryId: 1, search: 'melati');
      expect(request.path, '/products');
      expect(request.queryParameters, {
        'category_id': 1,
        'search': 'melati',
        'page': 2,
      });
      expect(result.isSuccess, isTrue);
      expect(result.data!.products.single.cheapestVariant.price, 250000);
      expect(result.data!.lastPage, 3);
    },
  );
}
