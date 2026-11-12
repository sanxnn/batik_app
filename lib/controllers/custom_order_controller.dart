import 'package:flutter/foundation.dart';

import '../core/utils/api_error.dart';
import '../models/custom_order_model.dart';
import '../services/custom_order_service.dart';

class CustomOrderController extends ChangeNotifier {
  final CustomOrderService service;

  CustomOrderController({CustomOrderService? service})
    : service = service ?? CustomOrderService();

  List<CustomOrderModel> orders = [];
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  int _page = 0;
  int _lastPage = 1;

  bool get canLoadMore => _page < _lastPage && !isLoading;

  Future<void> load({bool refresh = false}) async {
    if (isLoading) return;
    if (refresh) {
      _page = 0;
      _lastPage = 1;
      orders = [];
    }
    if (_page >= _lastPage) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await service.getOrders(page: _page + 1);
      orders = [...orders, ...result.orders];
      _page = result.currentPage;
      _lastPage = result.lastPage;
    } catch (error) {
      errorMessage = apiErrorMessage(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<CustomOrderModel?> create(String description) async {
    if (isSaving) return null;
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final order = await service.create(description);
      orders = [order, ...orders];
      return order;
    } catch (error) {
      errorMessage = apiErrorMessage(error);
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> cancel(int id) async {
    if (isSaving) return false;
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final order = await service.cancel(id);
      final index = orders.indexWhere((item) => item.id == id);
      if (index >= 0) orders[index] = order;
      return true;
    } catch (error) {
      errorMessage = apiErrorMessage(error);
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<int?> approve(int id, {required int addressId, String? notes}) async {
    if (isSaving) return null;
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await service.approve(
        id,
        addressId: addressId,
        notes: notes,
      );
      await load(refresh: true);
      return result.orderId;
    } catch (error) {
      errorMessage = apiErrorMessage(error);
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
