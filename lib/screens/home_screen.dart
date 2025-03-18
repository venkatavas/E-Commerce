import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedSort;
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _minRating = 0;

  @override
  void initState() {
    super.initState();
    // Load products after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Category filter
                Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return FutureBuilder<List<String>>(
                      future: productProvider.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        final categories = snapshot.data ?? [];

                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            ...categories.map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                )),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedCategory = value);
                            productProvider.setCategory(value);
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Sort options
                DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Default'),
                    ),
                    DropdownMenuItem(
                      value: 'price_asc',
                      child: Text('Price: Low to High'),
                    ),
                    DropdownMenuItem(
                      value: 'price_desc',
                      child: Text('Price: High to Low'),
                    ),
                    DropdownMenuItem(
                      value: 'rating',
                      child: Text('Rating'),
                    ),
                    DropdownMenuItem(
                      value: 'popularity',
                      child: Text('Popularity'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSort = value);
                    context.read<ProductProvider>().setSort(value);
                  },
                ),
                const SizedBox(height: 16),
                // Price range
                const Text('Price Range'),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  labels: RangeLabels(
                    '\$${_priceRange.start.round()}',
                    '\$${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setState(() => _priceRange = values);
                    context.read<ProductProvider>().setPriceRange(
                          values.start,
                          values.end,
                        );
                  },
                ),
                const SizedBox(height: 16),
                // Rating filter
                const Text('Minimum Rating'),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _minRating = value);
                    context.read<ProductProvider>().setMinRating(value);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedSort = null;
                            _priceRange = const RangeValues(0, 1000);
                            _minRating = 0;
                          });
                          context.read<ProductProvider>().clearFilters();
                        },
                        child: const Text('Clear Filters'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Commerce App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().clearFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<ProductProvider>().clearFilters();
                } else {
                  context.read<ProductProvider>().searchProducts(value);
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading products...'),
                      ],
                    ),
                  );
                }

                if (productProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          productProvider.error!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => productProvider.loadProducts(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final products = productProvider.products;
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products available',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => productProvider.loadProducts(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200) {
                      if (productProvider.hasMore) {
                        productProvider.loadProducts();
                      }
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount:
                        products.length + (productProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == products.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(
                                productId: product.id.toString(),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          size: 32,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber[700],
                                        ),
                                        Text(
                                          ' ${product.rating.rate.toStringAsFixed(1)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
