import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  final Dio _dio = ApiClient.instance.dio;

  // Mengambil data keranjang
  Future<CartModel> getCart() async {
    final response = await _dio.get('/cart');
    return _parseCart(response.data);
  }

  // Menambahkan produk ke keranjang
  Future<CartModel> addToCart({
    required VariantModel variant,
    required int quantity,
  }) async {
    final response = await _dio.post(
      '/cart/items',
      data: {'product_variant_id': variant.id, 'quantity': quantity},
    );

    return _parseCart(response.data);
  }

  // Mengubah jumlah produk
  Future<CartModel> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    final response = await _dio.put(
      '/cart/items/$itemId',
      data: {'quantity': quantity},
    );

    return _parseCart(response.data);
  }

  // Menghapus satu produk
  Future<CartModel> removeItem(int itemId) async {
    final response = await _dio.delete('/cart/items/$itemId');
    return _parseCart(response.data);
  }

  // Mengosongkan keranjang
  Future<CartModel> clearCart() async {
    final response = await _dio.delete('/cart');
    return _parseCart(response.data);
  }

  CartModel _parseCart(dynamic responseData) {
    final data = responseData['data'];

    if (data == null || data is! Map) {
      throw Exception('Format respons keranjang tidak valid.');
    }

    return CartModel.fromJson(Map<String, dynamic>.from(data));
  }
}
