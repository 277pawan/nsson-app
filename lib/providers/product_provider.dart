import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService.instance;
  static const List<String> _categoryOrder = [
    'fiber parts',
    'body parts',
    'engine parts',
    'braking system',
    'electricals',
    'tyres & tubes',
    'lubricants',
  ];

  List<Product> _products = [];
  List<Brand> _brands = [];
  List<Category> _categories = [];
  List<PromoBanner> _banners = [];
  bool _loading = false;
  String? _error;

  // Track if data has been initialized from API
  bool _initialized = false;
  bool _initFromApiSuccessful = false;

  String _normalize(String value) => value.trim().toLowerCase();

  /// Corrects known category name misspellings from the backend.
  String _fixCategoryName(String name) {
    switch (name.trim().toLowerCase()) {
      case 'breaking system':
        return 'Braking System';
      case 'lubricant':
      case 'lubrican':
        return 'Lubricants';
      default:
        return name;
    }
  }

  /// Normalises brand name variants (e.g. "Ns son" → "NSSON").
  String _fixBrandName(String name) {
    if (name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '') == 'nsson') {
      return 'NSSON';
    }
    return name;
  }

  bool _matchesFilter(String candidate, String filter, String resolvedName) {
    final normalizedCandidate = _normalize(candidate);
    final normalizedFilter = _normalize(filter);
    final normalizedResolvedName = _normalize(resolvedName);
    return normalizedCandidate == normalizedFilter ||
        normalizedCandidate == normalizedResolvedName;
  }

  List<Brand> _mergeAndSortBrands(List<Brand> remoteBrands) {
    final mergedByName = <String, Brand>{};

    for (final brand in DummyData.brands) {
      mergedByName[_normalize(brand.name)] = brand;
    }

    for (final brand in remoteBrands) {
      final fixedName = _fixBrandName(brand.name);
      final key = _normalize(fixedName);
      final fallback = mergedByName[key];
      mergedByName[key] = Brand(
        id: brand.id.isNotEmpty ? brand.id : (fallback?.id ?? brand.name),
        name: fixedName.isNotEmpty ? fixedName : (fallback?.name ?? ''),
        logo: brand.logo.isNotEmpty ? brand.logo : (fallback?.logo ?? ''),
      );
    }

    final brands =
        mergedByName.values.where((brand) => brand.name.isNotEmpty).toList();
    brands.sort((a, b) {
      final aPriority = _normalize(a.name) == 'nsson' ? 0 : 1;
      final bPriority = _normalize(b.name) == 'nsson' ? 0 : 1;
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return brands;
  }

  List<Category> _mergeAndSortCategories(List<Category> remoteCategories) {
    final mergedByName = <String, Category>{};

    for (final category in DummyData.categories) {
      mergedByName[_normalize(category.name)] = category;
    }

    for (final category in remoteCategories) {
      final fixedName = _fixCategoryName(category.name);
      final key = _normalize(fixedName);
      final fallback = mergedByName[key];
      mergedByName[key] = Category(
        id: category.id.isNotEmpty
            ? category.id
            : (fallback?.id ?? category.name),
        name: fixedName.isNotEmpty ? fixedName : (fallback?.name ?? ''),
        icon: fallback?.icon ?? category.icon,
      );
    }

    final categories = mergedByName.values
        .where((category) => category.name.isNotEmpty)
        .toList();

    int categoryRank(Category category) {
      final index = _categoryOrder.indexOf(_normalize(category.name));
      return index == -1 ? _categoryOrder.length : index;
    }

    categories.sort((a, b) {
      final aRank = categoryRank(a);
      final bRank = categoryRank(b);
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return categories;
  }

  List<Product> _applyProductFilters(
    List<Product> products, {
    String? category,
    String? brand,
  }) {
    var filtered = products;
    if (category != null && category.isNotEmpty) {
      final resolvedCategoryName = categoryName(category);
      filtered = filtered
          .where((product) =>
              _matchesFilter(product.category, category, resolvedCategoryName))
          .toList();
    }
    if (brand != null && brand.isNotEmpty) {
      final resolvedBrandName = brandName(brand);
      filtered = filtered
          .where((product) =>
              _matchesFilter(product.brand, brand, resolvedBrandName))
          .toList();
    }
    return filtered;
  }

  List<Product> get products => List.unmodifiable(_products);
  List<Brand> get brands => List.unmodifiable(_brands);
  List<Category> get categories => List.unmodifiable(_categories);
  List<PromoBanner> get banners => List.unmodifiable(_banners);
  bool get loading => _loading;
  String? get error => _error;

  /// Fetch all products from the backend.
  /// Prioritizes API data, falls back to dummy data only if API is unavailable.
  Future<void> fetchProducts({String? category, String? brand}) async {
    _loading = true;
    notifyListeners();
    try {
      String path = '/products';
      final queryParams = <String>[];
      if (category != null) queryParams.add('category=$category');
      if (brand != null) queryParams.add('brand=$brand');
      if (queryParams.isNotEmpty) path += '?${queryParams.join('&')}';

      final res = await _api.get(path);
      final rawProducts = res['products'] as List<dynamic>? ?? [];

      if (rawProducts.isNotEmpty) {
        // API returned real data
        final remoteProducts = rawProducts
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        _products = _applyProductFilters(
          remoteProducts,
          category: category,
          brand: brand,
        );
        _initFromApiSuccessful = true;
        _error = null;
      } else {
        // API returned empty list, use dummy data as fallback
        _products = _applyProductFilters(
          DummyData.products,
          category: category,
          brand: brand,
        );
        _error = null;
      }
    } catch (e) {
      // API call failed, use dummy data as fallback
      _products = _applyProductFilters(
        DummyData.products,
        category: category,
        brand: brand,
      );
      _error = 'Failed to fetch products: $e';
    }
    _loading = false;
    notifyListeners();
  }

  /// Fetch a single product by ID.
  Future<Product?> fetchProductById(String id) async {
    try {
      final res = await _api.get('/products/$id');
      return Product.fromJson(res['product'] as Map<String, dynamic>);
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  /// Fetch all brands from the backend.
  /// Prioritizes API data, merges with dummy data if needed.
  Future<void> fetchBrands() async {
    try {
      final res = await _api.get('/brands');
      final rawBrands = (res['brands'] ?? res['data'] ?? []) as List<dynamic>;

      if (rawBrands.isNotEmpty) {
        final remoteBrands = rawBrands
            .map((e) => Brand.fromJson(e as Map<String, dynamic>))
            .toList();
        _brands = _mergeAndSortBrands(remoteBrands);
      } else {
        // API returned empty, use dummy brands
        _brands = _mergeAndSortBrands(const <Brand>[]);
      }
      notifyListeners();
    } catch (e) {
      // API failed, use dummy brands for fallback
      _brands = _mergeAndSortBrands(const <Brand>[]);
      _error = 'Failed to fetch brands: $e';
    }
  }

  /// Fetch all categories from the backend.
  /// Prioritizes API data, merges with dummy data if needed.
  Future<void> fetchCategories() async {
    try {
      final res = await _api.get('/categories');
      final rawCats = (res['categories'] ?? res['data'] ?? []) as List<dynamic>;

      if (rawCats.isNotEmpty) {
        final remoteCategories = rawCats
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
        _categories = _mergeAndSortCategories(remoteCategories);
      } else {
        // API returned empty, use dummy categories
        _categories = _mergeAndSortCategories(const <Category>[]);
      }
      notifyListeners();
    } catch (e) {
      // API failed, use dummy categories
      _categories = _mergeAndSortCategories(const <Category>[]);
      _error = 'Failed to fetch categories: $e';
    }
  }

  /// Fetch all banners from the backend (no live filter — show all).
  /// Non-critical — keeps the list empty on failure.
  Future<void> fetchBanners() async {
    try {
      final res = await _api.get('/banners');
      debugPrint('[ProductProvider] fetchBanners response: $res');

      // Backend may return banners under different keys. Support common formats:
      // - { banners: [...] }
      // - { data: [...] }
      // - { ... } where the list is under 'banners' or 'data'
      List<dynamic> rawBanners = [];
      String usedKey = 'none';
      if (res.containsKey('banners') && res['banners'] is List) {
        rawBanners = res['banners'] as List<dynamic>;
        usedKey = 'banners';
      } else if (res.containsKey('data') && res['data'] is List) {
        rawBanners = res['data'] as List<dynamic>;
        usedKey = 'data';
      } else if (res is List) {
        rawBanners = res as List<dynamic>;
        usedKey = 'root';
      }

      debugPrint('[ProductProvider] using key="$usedKey" rawBanners.length=${rawBanners.length}');
      if (rawBanners.isNotEmpty) debugPrint('[ProductProvider] first banner: ${rawBanners.first}');
      if (rawBanners.isNotEmpty) {
        _banners = rawBanners
            .map((e) => PromoBanner.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      // Banners are non-critical — keep the list empty on failure
      debugPrint('Failed to fetch banners: $e');
    }
  }

  /// Load all initial data from the API.
  /// This ensures the app starts with fresh data from backend.
  /// Call this once during app initialization.
  Future<void> loadAll() async {
    if (_initialized && _initFromApiSuccessful) {
      // Already initialized successfully, don't reload unless explicitly needed
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchProducts(),
        fetchBrands(),
        fetchCategories(),
        fetchBanners(),
      ]);
      _initialized = true;
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      _error = 'Failed to load data';
    }

    _loading = false;
    notifyListeners();
  }

  /// Force refresh all data from API (e.g., when user pulls-to-refresh).
  /// This ignores the initialized flag and fetches fresh data.
  Future<void> refreshAll() async {
    _loading = true;
    notifyListeners();

    try {
      await Future.wait([
        fetchProducts(),
        fetchBrands(),
        fetchCategories(),
        fetchBanners(),
      ]);
      _initialized = true;
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      _error = 'Failed to refresh data';
    }

    _loading = false;
    notifyListeners();
  }

  String brandName(String brandId) {
    final brand = _brands.firstWhere(
      (b) => b.id == brandId || b.name.toLowerCase() == brandId.toLowerCase(),
      orElse: () => Brand(id: brandId, name: brandId, logo: ''),
    );
    return brand.name;
  }

  String categoryName(String categoryId) {
    final cat = _categories.firstWhere(
      (c) =>
          c.id == categoryId ||
          c.name.toLowerCase() == categoryId.toLowerCase(),
      orElse: () =>
          Category(id: categoryId, name: categoryId, icon: Icons.category),
    );
    return cat.name;
  }

  /// Check if data has been initialized from API
  bool get isInitialized => _initialized;

  /// Check if initialization from API was successful
  bool get isInitFromApiSuccessful => _initFromApiSuccessful;

  /// Get count of real products (not from dummy data)
  int get realProductCount => _products.length;
}
