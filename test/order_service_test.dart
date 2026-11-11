import 'package:batik_app/services/order_service.dart';
import 'package:batik_app/core/network/payment_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Dio fakeDio(Map<String, dynamic> Function(RequestOptions) respond) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response(requestOptions: options, data: respond(options)),
        );
      },
    ),
  );
  return dio;
}

void main() {
  test(
    'checkout sends address and optional fields only, parses nested order',
    () async {
      late RequestOptions request;
      final service = OrderService(
        dio: fakeDio((options) {
          request = options;
          return {
            'data': {
              'order': {
                'id': 25,
                'order_number': 'BRK-25',
                'status': 'pending_payment',
                'pricing': {
                  'subtotal': 500000,
                  'total_discount': 50000,
                  'shipping_cost': 20000,
                  'final_amount': 470000,
                },
                'items': [
                  {
                    'product_name': 'Batik',
                    'variant_name': '2 Meter',
                    'quantity': 2,
                    'subtotal': 500000,
                  },
                ],
              },
              'payment': {'snap_token': null},
            },
          };
        }),
      );
      final result = await service.checkout(
        addressId: 3,
        voucherCode: 'HEMAT10',
      );
      expect(request.path, '/orders');
      expect(request.data, {'address_id': 3, 'voucher_code': 'HEMAT10'});
      expect(result.order.id, 25);
      expect(result.order.total, 470000);
      expect(result.order.items.single.quantity, 2);
      expect(result.snapToken, isNull);
    },
  );

  test('orders collection reads resource pagination metadata', () async {
    final service = OrderService(
      dio: fakeDio(
        (options) => {
          'data': [
            {
              'id': 1,
              'order_number': 'BRK-1',
              'status': 'paid',
              'pricing': {'final_amount': 100000},
            },
          ],
          'meta': {'current_page': 2, 'last_page': 4},
        },
      ),
    );
    final page = await service.getOrders(page: 2);
    expect(page.orders.single.number, 'BRK-1');
    expect(page.currentPage, 2);
    expect(page.lastPage, 4);
  });

  test('payment token accepts both success response shapes', () async {
    final created = OrderService(
      dio: fakeDio((options) => {
        'data': {'order_number': 'BRK-25', 'amount': 470000,
          'snap_token': 'created-token'},
      }),
    );
    final service = OrderService(
      dio: fakeDio(
        (options) => {
          'data': {'payment_status': 'pending', 'snap_token': 'token-123'},
        },
      ),
    );
    expect(await created.getSnapToken(25), 'created-token');
    expect(await service.getSnapToken(25), 'token-123');
  });

  test('Snap URL uses the configured environment and token', () {
    expect(
      PaymentLauncher.snapUri('abc-123').toString(),
      'https://app.sandbox.midtrans.com/snap/v2/vtweb/abc-123',
    );
  });
}
