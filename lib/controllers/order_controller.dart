import 'package:flutter/foundation.dart';

import '../core/utils/api_error.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  final OrderService service;
  OrderController({OrderService? service})
    : service = service ?? OrderService();

  List<OrderModel> orders = [];
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

  Future<OrderModel?> refreshDetail(int id) async {
    try {
      final order = await service.getOrder(id);
      final index = orders.indexWhere((item) => item.id == id);
      if (index >= 0) {
        orders[index] = order;
        notifyListeners();
      }
      errorMessage = null;
      return order;
    } catch (error) {
      errorMessage = apiErrorMessage(error);
      notifyListeners();
      return null;
    }
  }

  Future<CheckoutResult?> checkout({
    required int addressId,
    String? voucherCode,
    String? notes,
  }) async {
    if (isSaving) return null;
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await service.checkout(
        addressId: addressId,
        voucherCode: voucherCode,
        notes: notes,
      );
      orders = [
        result.order,
        ...orders.where((order) => order.id != result.order.id),
      ];
      return result;
    } catch (error) {
      errorMessage = apiErrorMessage(error);
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> paymentToken(int id) async {
    if (isSaving) return null;
    isSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final token = await service.getSnapToken(id);
      if (token == null || token.isEmpty) {
        errorMessage = 'Token pembayaran belum tersedia.';
      }
      return token;
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
      final order = await service.cancelOrder(id);
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

  void clear() {
    orders = [];
    _page = 0;
    _lastPage = 1;
    errorMessage = null;
    notifyListeners();
  }
}
