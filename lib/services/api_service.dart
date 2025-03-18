import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // Authentication methods
  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        // For demo purposes, we'll create a user with the token
        return User(
          id: '1',
          email: '$username@example.com',
          username: username,
          password: password,
          name: 'Demo User',
          phone: '1234567890',
        );
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<User> register(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Existing product methods
  Future<List<Product>> getProducts({
    int limit = 10,
    int offset = 0,
    String? sortBy,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
  }) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Product> products =
            data.map((json) => Product.fromJson(json)).toList();

        // Apply filters
        if (category != null) {
          products = products.where((p) => p.category == category).toList();
        }
        if (minPrice != null) {
          products = products.where((p) => p.price >= minPrice).toList();
        }
        if (maxPrice != null) {
          products = products.where((p) => p.price <= maxPrice).toList();
        }
        if (minRating != null) {
          products = products.where((p) => p.rating.rate >= minRating).toList();
        }

        // Apply sorting
        if (sortBy != null) {
          switch (sortBy) {
            case 'price_asc':
              products.sort((a, b) => a.price.compareTo(b.price));
              break;
            case 'price_desc':
              products.sort((a, b) => b.price.compareTo(a.price));
              break;
            case 'rating':
              products.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
              break;
            case 'popularity':
              products.sort((a, b) => b.rating.count.compareTo(a.rating.count));
              break;
          }
        }

        // Apply pagination
        return products.skip(offset).take(limit).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Product> products =
            data.map((json) => Product.fromJson(json)).toList();

        return products
            .where((product) =>
                product.title.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Existing methods
  Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/categories'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/products/category/$category'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products by category');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
