import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends ChangeNotifier {
  final ProductService _service;
  ProductController({ProductService? service})
    : _service = service ?? ProductService();
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedCategoryId;
  String _searchQuery = '';
  int _page = 0;
  int _lastPage = 1;
  int _generation = 0;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get canLoadMore => _page < _lastPage && !_isLoading;

  Future<void> fetchInitialData() async {
    final categories = await _service.getCategories();
    if (categories.isSuccess) {
      _categories = categories.data!;
      notifyListeners();
    }
    await _refresh();
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    await _refresh();
  }

  void selectCategory(int? id) {
    _selectedCategoryId = _selectedCategoryId == id ? null : id;
    _searchQuery = '';
    _refresh();
  }

  Future<void> fetchProductsByCategory(int? id) async {
    _selectedCategoryId = id;
    await _refresh();
  }

  void resetFilters() {
    _selectedCategoryId = null;
    _searchQuery = '';
    _refresh();
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    _page = 0;
    _lastPage = 1;
    _products = [];
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    await _loadPage(generation, 1);
  }

  Future<void> loadMore() async {
    if (!canLoadMore) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _loadPage(_generation, _page + 1);
  }

  Future<void> _loadPage(int generation, int page) async {
    final result = await _service.getProducts(
      categoryId: _selectedCategoryId,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      page: page,
    );
    if (generation != _generation) return;
    if (result.isSuccess) {
      _products = page == 1
          ? result.data!.products
          : [..._products, ...result.data!.products];
      _page = result.data!.currentPage;
      _lastPage = result.data!.lastPage;
      _errorMessage = null;
    } else {
      _errorMessage = result.message;
    }
    _isLoading = false;
    notifyListeners();
  }
}
