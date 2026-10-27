import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];

  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedCategoryId;
  String _searchQuery = '';

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final categoriesResult = await _productService.getCategories();
      final productsResult = await _productService.getProducts();

      if (categoriesResult.isSuccess) {
        _categories = categoriesResult.data!;
      }
      if (productsResult.isSuccess) {
        _products = productsResult.data!;
      } else {
        _errorMessage = productsResult.message;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tak terduga.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        search: query.isEmpty ? null : query,
      );

      if (result.isSuccess) {
        _products = result.data!;
      } else {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal mencari produk.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(int? id) {
    _selectedCategoryId = _selectedCategoryId == id ? null : id;
    _searchQuery = ''; // Reset search saat ganti kategori
    notifyListeners();
    fetchProductsByCategory(_selectedCategoryId);
  }

  Future<void> fetchProductsByCategory(int? categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _productService.getProducts(categoryId: categoryId);
      if (result.isSuccess) {
        _products = result.data!;
      } else {
        _errorMessage = result.message;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat produk kategori ini.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    fetchInitialData();
  }
}
