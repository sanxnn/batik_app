import 'package:batik_app/services/bundle_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundle service reads resource collection pagination', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'data': [
                  {
                    'id': 22,
                    'name': 'Paket Melati',
                    'slug': 'paket-melati',
                    'variants': [
                      {
                        'id': 55,
                        'name': 'Paket A',
                        'sku': 'BND-A',
                        'price': 300000,
                        'stock': 3,
                        'components': [
                          {
                            'variant_id': 41,
                            'name': '2 Meter',
                            'sku': 'BT-2M',
                            'quantity': 1,
                            'stock': 5,
                            'product': {'name': 'Batik Melati'},
                          },
                        ],
                      },
                    ],
                  },
                ],
                'meta': {'current_page': 1, 'last_page': 2},
              },
            ),
          );
        },
      ),
    );

    final page = await BundleService(dio: dio).getBundles();

    expect(page.bundles.single.name, 'Paket Melati');
    expect(
      page.bundles.single.variants.single.components.single.productName,
      'Batik Melati',
    );
    expect(page.lastPage, 2);
  });
}
