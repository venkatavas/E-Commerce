import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  String? _currentCategory;
  String? _currentSort;
  double? _minPrice;
  double? _maxPrice;
  double? _minRating;
  String? _searchQuery;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _products = [];
      _filteredProducts = [];
    }

    if (!_hasMore || _isLoading) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newProducts = await _apiService.getProducts(
        limit: 10,
        offset: _currentPage * 10,
        sortBy: _currentSort,
        category: _currentCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minRating: _minRating,
      );

      _products.addAll(newProducts);
      _hasMore = newProducts.length == 10;
      _currentPage++;

      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 0;
    _hasMore = true;
    _products = [];
    _filteredProducts = [];

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final results = await _apiService.searchProducts(query);
      _products = results;
      _filteredProducts = results;
      _hasMore = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  void setCategory(String? category) {
    _currentCategory = category;
    _applyFilters();
  }

  void setSort(String? sort) {
    _currentSort = sort;
    _applyFilters();
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
  }

  void setMinRating(double? rating) {
    _minRating = rating;
    _applyFilters();
  }

  void _applyFilters() {
    if (_searchQuery != null) {
      _filteredProducts = _products
          .where((product) =>
              product.title
                  .toLowerCase()
                  .contains(_searchQuery!.toLowerCase()) ||
              product.description
                  .toLowerCase()
                  .contains(_searchQuery!.toLowerCase()))
          .toList();
    } else {
      _filteredProducts = List.from(_products);
    }

    if (_currentCategory != null) {
      _filteredProducts = _filteredProducts
          .where((p) => p.category == _currentCategory)
          .toList();
    }

    if (_minPrice != null) {
      _filteredProducts =
          _filteredProducts.where((p) => p.price >= _minPrice!).toList();
    }

    if (_maxPrice != null) {
      _filteredProducts =
          _filteredProducts.where((p) => p.price <= _maxPrice!).toList();
    }

    if (_minRating != null) {
      _filteredProducts =
          _filteredProducts.where((p) => p.rating.rate >= _minRating!).toList();
    }

    if (_currentSort != null) {
      switch (_currentSort) {
        case 'price_asc':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'rating':
          _filteredProducts
              .sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
          break;
        case 'popularity':
          _filteredProducts
              .sort((a, b) => b.rating.count.compareTo(a.rating.count));
          break;
      }
    }

    notifyListeners();
  }

  void clearFilters() {
    _currentCategory = null;
    _currentSort = null;
    _minPrice = null;
    _maxPrice = null;
    _minRating = null;
    _searchQuery = null;
    _applyFilters();
  }

  Future<void> addProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _products.add(product);
    } catch (e) {
      _error = 'Failed to add product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
      }
    } catch (e) {
      _error = 'Failed to update product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _products.removeWhere((product) => product.id == id);
    } catch (e) {
      _error = 'Failed to delete product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getCategories() async {
    if (_products.isEmpty) {
      await loadProducts();
    }
    return _products.map((p) => p.category).toSet().toList()..sort();
  }
}
