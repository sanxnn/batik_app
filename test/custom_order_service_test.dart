import 'package:batik_app/services/custom_order_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';

void main() {
  test(
    'custom order service parses quotation pagination and create payload',
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
                  'data': [
                    {
                      'id': 4,
                      'reference_number': 'CO-4',
                      'description': 'Batik biru untuk acara keluarga',
                      'status': 'quoted',
                      'estimated_price': 400000,
                      'estimated_time': '14 hari',
                    },
                  ],
                  'meta': {'current_page': 1, 'last_page': 1},
                },
              ),
            );
          },
        ),
      );

      final service = CustomOrderService(dio: dio);
      final page = await service.getOrders();

      expect(page.orders.single.referenceNumber, 'CO-4');
      expect(page.orders.single.estimatedPrice, 400000);
      expect(page.lastPage, 1);

      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': {
                    'id': 5,
                    'reference_number': 'CO-5',
                    'description': 'Batik merah custom panjang',
                    'status': 'pending_review',
                  },
                },
              ),
            );
          },
        ),
      );

      final created = await service.create('Batik merah custom panjang');

      expect(request.path, '/custom-orders');
      expect(request.data, {'description': 'Batik merah custom panjang'});
      expect(created.id, 5);
    },
  );

  test(
    'custom order sends multipart attachments and parses returned paths',
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
                    'id': 5,
                    'reference_number': 'CO-5',
                    'description': 'Batik custom',
                    'status': 'pending_review',
                    'attachments': [
                      {'file_path': 'custom-orders/sample.png'},
                    ],
                  },
                },
              ),
            );
          },
        ),
      );
      final service = CustomOrderService(dio: dio);
      final file = XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        path: '/tmp/sample.png',
        name: 'sample.png',
      );

      final created = await service.create('Batik custom', attachments: [file]);
      final updated = await service.addAttachments(5, [file]);

      expect(requests.first.data, isA<FormData>());
      expect(requests.first.contentType, Headers.multipartFormDataContentType);
      expect(
        (requests.first.data as FormData).fields.single.key,
        'description',
      );
      expect(
        (requests.first.data as FormData).fields.single.value,
        'Batik custom',
      );
      expect(
        (requests.first.data as FormData).files.single.key,
        'attachments[]',
      );
      expect(requests.last.path, '/custom-orders/5/attachments');
      expect(
        (requests.last.data as FormData).files.single.value.filename,
        'sample.png',
      );
      expect(created.attachments.single.filePath, 'custom-orders/sample.png');
      expect(updated.attachments.single.filePath, 'custom-orders/sample.png');
    },
  );
}
