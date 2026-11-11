
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService _service = CartService();

  CartModel? _cart;

  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  CartModel? get cart => _cart;

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;

  String? get errorMessage => _errorMessage;

  List<CartItemModel> get items => _cart?.items ?? [];

  int get totalItems => _cart?.totalItems ?? 0;

  double get totalPrice => _cart?.totalPrice ?? 0;

  bool get isEmpty => items.isEmpty;

  void clearLocal() {
    _cart = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Mengambil keranjang
  Future<void> fetchCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _service.getCart();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan produk
  Future<bool> addToCart({
    required ProductModel product,
    required VariantModel variant,
    required int quantity,
  }) async {
    _errorMessage = null;

    try {
      _cart = await _service.addToCart(
        variant: variant,
        quantity: quantity,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Mengubah jumlah produk
  Future<bool> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    if (quantity < 1) return false;

    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _service.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );

      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Menghapus produk
  Future<bool> removeItem(int itemId) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _service.removeItem(itemId);
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Mengosongkan keranjang
  Future<bool> clearCart() async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _service.clearCart();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Mengambil pesan error dari Dio / Laravel
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;

          if (errors.isNotEmpty) {
            final firstError = errors.values.first;

            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
        }

        if (data['message'] != null) {
          return data['message'].toString();
        }
      }

      if (error.response?.statusCode == 401) {
        return 'Sesi login berakhir. Silakan login kembali.';
      }

      return error.message ?? 'Terjadi kesalahan pada server.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}
