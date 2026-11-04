import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CartItemModel {
  final int cartItemId;
  final ProductModel product;
  final VariantModel variant;
  int quantity;

  CartItemModel({
    required this.cartItemId,
    required this.product,
    required this.variant,
    required this.quantity,
  });
}

class CartController extends ChangeNotifier {
  static const String _storageKey = 'local_cart_items_v13';
  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CartController() {
    fetchCart();
  }

  // 1. Simpan Data Keranjang ke SharedPreferences (Sesuai persis dengan Json model kamu)
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = _items.map((item) {
        return jsonEncode({
          'cartItemId': item.cartItemId,
          'product': {
            'id': item.product.id,
            'name': item.product.name,
            'slug': item.product.slug,
            'description': item.product.description,
            'image': item.product.image,
          },
          'variant': {
            'id': item.variant.id,
            'name': item.variant.name,
            'sku': item.variant.sku,
            'price': item.variant.price,
            'stock': item.variant.stock,
          },
          'quantity': item.quantity,
        });
      }).toList();
      await prefs.setStringList(_storageKey, rawList);
    } catch (e) {
      debugPrint('Gagal menyimpan keranjang: $e');
    }
  }

  // 2. Baca Data dari Storage pakai ProductModel.fromJson & VariantModel.fromJson milikmu
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? rawList = prefs.getStringList(_storageKey);

      if (rawList != null && rawList.isNotEmpty) {
        _items = rawList.map((str) {
          final Map<String, dynamic> jsonMap = jsonDecode(str);
          final productMap = Map<String, dynamic>.from(jsonMap['product'] as Map);
          final variantMap = Map<String, dynamic>.from(jsonMap['variant'] as Map);

          final productObj = ProductModel.fromJson(productMap);
          final variantObj = VariantModel.fromJson(variantMap);

          return CartItemModel(
            cartItemId: jsonMap['cartItemId'] as int? ?? DateTime.now().millisecondsSinceEpoch,
            product: productObj,
            variant: variantObj,
            quantity: jsonMap['quantity'] as int? ?? 1,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Gagal membaca keranjang: $e');
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Tambah Produk ke Keranjang
  Future<bool> addToCart({
    required ProductModel product,
    required VariantModel variant,
    required int quantity,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _items.indexWhere(
        (item) => item.product.id == product.id && item.variant.id == variant.id,
      );

      if (index != -1) {
        _items[index].quantity += quantity;
      } else {
        _items.add(
          CartItemModel(
            cartItemId: DateTime.now().millisecondsSinceEpoch,
            product: product,
            variant: variant,
            quantity: quantity,
          ),
        );
      }

      await _saveToStorage();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan produk ke keranjang';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Tambah Jumlah (+1)
  Future<void> incrementQuantity(CartItemModel item) async {
    final index = _items.indexWhere((element) => element.cartItemId == item.cartItemId);
    if (index != -1) {
      _items[index].quantity++;
      await _saveToStorage();
      notifyListeners();
    }
  }

  // 5. Kurangi Jumlah (-1)
  Future<void> decrementQuantity(CartItemModel item) async {
    final index = _items.indexWhere((element) => element.cartItemId == item.cartItemId);
    if (index != -1 && _items[index].quantity > 1) {
      _items[index].quantity--;
      await _saveToStorage();
      notifyListeners();
    }
  }

  // 6. Hapus Item Terpilih
  Future<void> removeSelectedItems(List<int> cartItemIds) async {
    _items.removeWhere((item) => cartItemIds.contains(item.cartItemId));
    await _saveToStorage();
    notifyListeners();
  }

  // 7. Bersihkan Keranjang
  Future<void> clearCart() async {
    _items.clear();
    await _saveToStorage();
    notifyListeners();
  }
}