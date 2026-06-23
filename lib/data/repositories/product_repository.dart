import '../models.dart';
import '../../core/services/api_service.dart';

/// ProductRepository handles all API calls related to products, brands, categories, and banners.
/// This provides a clean separation between API logic and provider state management.
///
/// Benefits:
/// - Centralized API calls for products
/// - Easy to mock for testing
/// - Reusable across different providers
/// - Single source of truth for API endpoints
class ProductRepository {
  final ApiService _api = ApiService.instance;

  ProductRepository();

  /// Fetch all products with optional filters
  /// Returns: Map with 'success', 'products', and 'total' keys
  Future<List<Product>> fetchProducts({
    String? category,
    String? brand,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      String path = '/products?page=$page&limit=$limit';
      if (category != null && category.isNotEmpty) {
        path += '&category=$category';
      }
      if (brand != null && brand.isNotEmpty) {
        path += '&brand=$brand';
      }

      final response = await _api.get(path);
      final products = response['products'] as List<dynamic>? ?? [];

      return products
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Fetch a single product by ID
  Future<Product?> fetchProductById(String id) async {
    try {
      final response = await _api.get('/products/$id');
      return Product.fromJson(response['product'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Fetch all brands
  /// Returns: List<Brand>
  Future<List<Brand>> fetchBrands() async {
    try {
      final response = await _api.get('/brands');
      final brands =
          (response['brands'] ?? response['data'] ?? []) as List<dynamic>;

      return brands
          .map((b) => Brand.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch brands: $e');
    }
  }

  /// Fetch all categories
  /// Returns: List<Category>
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _api.get('/categories');
      final categories =
          (response['categories'] ?? response['data'] ?? []) as List<dynamic>;

      return categories
          .map((c) => Category.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Fetch active promotional banners
  /// Returns: List<PromoBanner>
  Future<List<PromoBanner>> fetchBanners() async {
    try {
      final response = await _api.get('/banners?live=true');
      final banners = (response['data'] ?? []) as List<dynamic>;

      return banners
          .map((b) => PromoBanner.fromJson(b as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }

  /// Search products by query
  /// Searches in: name, partNumber, description, brand
  /// Returns: List<Product>
  Future<List<Product>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }

      final response = await _api.get('/products/search?q=$query');
      final products = response['products'] as List<dynamic>? ?? [];

      return products
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  /// Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String categoryName) async {
    return fetchProducts(category: categoryName);
  }

  /// Fetch products by brand
  Future<List<Product>> fetchProductsByBrand(String brandName) async {
    return fetchProducts(brand: brandName);
  }

  /// Fetch products in stock (stock > 0)
  Future<List<Product>> fetchProductsInStock() async {
    try {
      final response = await _api.get('/products?inStock=true');
      final products = response['products'] as List<dynamic>? ?? [];

      return products
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch in-stock products: $e');
    }
  }

  /// Fetch low stock products (for admin awareness)
  Future<List<Product>> fetchLowStockProducts({int threshold = 20}) async {
    try {
      final response =
          await _api.get('/products?lowStock=true&threshold=$threshold');
      final products = response['products'] as List<dynamic>? ?? [];

      return products
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }
}
