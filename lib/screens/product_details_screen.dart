import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            final product = productProvider.products.firstWhere(
              (p) => p.id.toString() == productId,
              orElse: () => throw Exception('Product not found'),
            );
            return Text(product.title);
          },
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final product = productProvider.products.firstWhere(
            (p) => p.id.toString() == productId,
            orElse: () => throw Exception('Product not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
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
                const SizedBox(height: 16),
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber[700],
                    ),
                    Text(
                      ' ${product.rating.rate.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartProvider>().addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Product added to cart'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
