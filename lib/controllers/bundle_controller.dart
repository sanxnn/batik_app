import 'package:flutter/foundation.dart';

import '../core/utils/api_error.dart';
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
  int _generation = 0;
  String _search = '';

  bool get canLoadMore => _page < _lastPage && !isLoading;

  Future<void> search(String query) {
    if (_search == query && (_page > 0 || isLoading)) return Future.value();
    _search = query;
    return load(refresh: true);
  }

  Future<void> load({bool refresh = false}) async {
    if (!refresh && !canLoadMore) return;
    if (refresh) {
      _generation++;
      _page = 0;
      _lastPage = 1;
      bundles = [];
    }
    final generation = _generation;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await service.getBundles(search: _search, page: _page + 1);
      if (generation != _generation) return;
      bundles = [...bundles, ...result.bundles];
      _page = result.currentPage;
      _lastPage = result.lastPage;
    } catch (error) {
      if (generation != _generation) return;
      errorMessage = apiErrorMessage(error);
    } finally {
      if (generation == _generation) {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
