import 'package:flutter/foundation.dart';

import '../models/bundle_model.dart';
import '../services/bundle_service.dart';

class BundleController extends ChangeNotifier {
  final BundleService service;

  BundleController({BundleService? service})
    : service = service ?? BundleService();

  List<BundleModel> bundles = [];
  bool isLoading = false;
  String? errorMessage;
  int _page = 0;
  int _lastPage = 1;

  bool get canLoadMore => _page < _lastPage && !isLoading;

  Future<void> load({bool refresh = false}) async {
    if (isLoading) return;
    if (refresh) {
      _page = 0;
      _lastPage = 1;
      bundles = [];
    }
    if (_page >= _lastPage) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await service.getBundles(page: _page + 1);
      bundles = [...bundles, ...result.bundles];
      _page = result.currentPage;
      _lastPage = result.lastPage;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
