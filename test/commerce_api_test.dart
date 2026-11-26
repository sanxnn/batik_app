import 'dart:typed_data';

import 'package:batik_app/models/order_model.dart';
import 'package:batik_app/services/custom_order_service.dart';
import 'package:batik_app/services/order_service.dart';
import 'package:batik_app/services/refund_service.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';

import 'order_service_test.dart' show fakeDio;

void main() {
  test(
    'voucher preview sends code and reads the pre-checkout subtotal',
    () async {
      final service = OrderService(
        dio: fakeDio((request) {
          expect(request.method, 'POST');
          expect(request.path, '/vouchers/validate');
          expect(request.data, {'code': 'batikhemat'});
          return {
            'data': {
              'code': 'BATIKHEMAT',
              'discount': 10000,
              'subtotal_after_voucher': 90000,
            },
          };
        }),
      );

      final preview = await service.validateVoucher('batikhemat');
      expect(preview.code, 'BATIKHEMAT');
      expect(preview.discount, 10000);
      expect(preview.subtotalAfterVoucher, 90000);
    },
  );

  test(
    'confirmation parses the returned order with shipping and refund',
    () async {
      final service = OrderService(
        dio: fakeDio((request) {
          expect(request.method, 'POST');
          expect(request.path, '/orders/25/complete');
          return {
            'data': {
              'id': 25,
              'status': 'completed',
              'shipping': {'courier': 'J&T', 'resi_number': 'RESI123'},
              'payment': {'payment_status': 'success'},
              'refund': {'id': 3, 'status': 'pending', 'amount': 250000},
            },
          };
        }),
      );

      final order = await service.completeOrder(25);
      expect(order.status, 'completed');
      expect(order.trackingNumber, 'RESI123');
      expect(order.refund?.id, 3);
      expect(order.canComplete, isFalse);
      expect(order.canRequestRefund, isFalse);
    },
  );

  test('late successful payment on a cancelled order can be refunded', () {
    OrderModel order(String payment, {String? status}) => OrderModel.fromJson({
      'id': 42,
      'status': 'cancelled',
      'payment': {'payment_status': payment},
      'refund': status == null
          ? null
          : {'id': 2, 'status': status, 'amount': 50000},
    });

    expect(order('pending').canRequestRefund, isFalse);
    expect(order('success').canRequestRefund, isTrue);
    expect(order('success', status: 'completed').canRequestRefund, isFalse);
    expect(order('success', status: 'rejected').canRequestRefund, isTrue);
    expect(order('success', status: 'cancelled').canRequestRefund, isTrue);
  });

  test(
    'refund submits a single multipart proof and reads its status',
    () async {
      final service = RefundService(
        dio: fakeDio((request) {
          expect(request.method, 'POST');
          expect(request.path, '/orders/42/refund');
          final data = request.data as FormData;
          expect(data.fields.single.key, 'reason');
          expect(data.files.single.key, 'evidence');
          expect(data.files.single.value.filename, 'bukti.png');
          return {
            'data': {'id': 3, 'status': 'pending', 'amount': '125000'},
          };
        }),
      );

      final refund = await service.submit(
        42,
        'Produk rusak saat saya terima.',
        XFile.fromData(Uint8List.fromList([1, 2, 3]), path: 'bukti.png'),
      );
      expect(refund.amount, 125000);
      expect(refund.status, 'pending');
    },
  );

  test('custom order uploads repeated attachments[] fields', () async {
    final service = CustomOrderService(
      dio: fakeDio((request) {
        expect(request.path, '/custom-orders/7/attachments');
        final data = request.data as FormData;
        expect(data.files.map((file) => file.key), [
          'attachments[]',
          'attachments[]',
        ]);
        return {
          'data': {
            'id': 7,
            'status': 'pending_review',
            'attachments': [
              {'file_path': 'custom-orders/a.png'},
              {'file_path': 'custom-orders/b.png'},
            ],
          },
        };
      }),
    );
    final result = await service.addAttachments(7, [
      XFile.fromData(Uint8List(1), name: 'a.png'),
      XFile.fromData(Uint8List(1), name: 'b.png'),
    ]);
    expect(result.attachmentPaths, hasLength(2));
  });
}
