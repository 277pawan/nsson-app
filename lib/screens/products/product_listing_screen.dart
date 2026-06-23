import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/animations.dart';
import '../../core/widgets/product_card.dart';
import '../../core/utils/cart_notification.dart';
import '../../data/models.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

class ProductListingScreen extends StatefulWidget {
  final String? filterCategory;
  final String? filterBrand;

  const ProductListingScreen({
    super.key,
    this.filterCategory,
    this.filterBrand,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts(
            category: widget.filterCategory,
            brand: widget.filterBrand,
          );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Product> _filteredProducts(ProductProvider productProv) {
    var products = productProv.products.toList();
    if (widget.filterCategory != null) {
      products =
          products.where((p) => p.category == widget.filterCategory).toList();
    }
    if (widget.filterBrand != null) {
      products = products.where((p) => p.brand == widget.filterBrand).toList();
    }
    if (_searchQuery.isNotEmpty) {
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.partNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.brand.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return products;
  }

  String _title(ProductProvider productProv) {
    if (widget.filterCategory != null) {
      return productProv.categoryName(widget.filterCategory!);
    }
    if (widget.filterBrand != null) {
      return productProv.brandName(widget.filterBrand!);
    }
    return 'All Products';
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final products = _filteredProducts(productProv);
    Widget content;

    if (productProv.loading && products.isEmpty) {
      content = const SingleChildScrollView(child: ProductListingSkeleton());
    } else if (products.isEmpty) {
      content = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    } else {
      content = RefreshIndicator(
        onRefresh: () => context.read<ProductProvider>().fetchProducts(
              category: widget.filterCategory,
              brand: widget.filterBrand,
            ),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, idx) {
            final product = products[idx];
            return StaggerAnimation(
              index: idx,
              child: ProductCard(
                product: product,
                onTap: () => Navigator.pushNamed(context, '/product-detail',
                    arguments: product),
                onAddToCart: () async {
                  final success =
                      await context.read<CartProvider>().addToCart(product);
                  if (!context.mounted) return;
                  if (success) {
                    showCartNotification(
                      context,
                      productName: product.name,
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.read<CartProvider>().error ??
                            'Unable to add item to cart.',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title(productProv)),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: AppColors.surface,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${products.length} product${products.length == 1 ? '' : 's'} found',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Product grid
          Expanded(child: content),
        ],
      ),
    );
  }
}
