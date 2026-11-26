import 'dart:typed_data';

import 'package:batik_app/services/refund_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test(
    'refund request uploads reason and evidence and reads its status',
    () async {
      final requests = <RequestOptions>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': {
                    'id': 7,
                    'order_id': 12,
                    'order_number': 'BRK-12',
                    'reason': 'Produk rusak saat diterima dan perlu refund',
                    'status': options.method == 'POST' ? 'pending' : 'approved',
                    'amount': 150000,
                    'admin_notes': 'Sedang diproses',
                  },
                },
              ),
            );
          },
        ),
      );

      final service = RefundService(dio: dio);
      final created = await service.submit(
        orderId: 12,
        reason: ' Produk rusak saat diterima dan perlu refund ',
        evidence: XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          path: '/tmp/bukti.jpg',
        ),
      );

      expect(requests.first.path, '/orders/12/refund');
      expect(requests.first.data, isA<FormData>());
      final form = requests.first.data as FormData;
      expect(form.fields.single.key, 'reason');
      expect(
        form.fields.single.value,
        'Produk rusak saat diterima dan perlu refund',
      );
      expect(form.files.single.key, 'evidence');
      expect(form.files.single.value.filename, 'bukti.jpg');
      expect(created.status, 'pending');

      final updated = await service.get(created.id);
      expect(requests.last.path, '/refunds/7');
      expect(updated.status, 'approved');
      expect(updated.adminNotes, 'Sedang diproses');
    },
  );
}
