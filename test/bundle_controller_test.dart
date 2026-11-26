import 'dart:async';

import 'package:batik_app/controllers/bundle_controller.dart';
import 'package:batik_app/models/bundle_model.dart';
import 'package:batik_app/services/bundle_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _DelayedBundleService extends BundleService {
  _DelayedBundleService() : super(dio: Dio());

  final pages = <(String?, int), Completer<BundlePage>>{};

  @override
  Future<BundlePage> getBundles({String? search, int page = 1}) =>
      (pages[(search, page)] = Completer<BundlePage>()).future;
}

BundleModel _bundle(int id) => BundleModel(
  id: id,
  name: 'Paket $id',
  slug: 'paket-$id',
  variants: const [],
);

void main() {
  test(
    'bundle search discards stale results and keeps the query for pagination',
    () async {
      final service = _DelayedBundleService();
      final controller = BundleController(service: service);
      addTearDown(controller.dispose);

      final initial = controller.load(refresh: true);
      final filtered = controller.search('kawung');
      service.pages[('kawung', 1)]!.complete(BundlePage([_bundle(2)], 1, 2));
      await filtered;
      service.pages[('', 1)]!.complete(BundlePage([_bundle(1)], 1, 1));
      await initial;
      expect(controller.bundles.map((item) => item.id), [2]);

      final more = controller.load();
      service.pages[('kawung', 2)]!.complete(BundlePage([_bundle(3)], 2, 2));
      await more;
      expect(controller.bundles.map((item) => item.id), [2, 3]);
      expect(controller.canLoadMore, isFalse);
    },
  );
}
