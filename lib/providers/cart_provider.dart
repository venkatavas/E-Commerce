import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id.toString())) {
      _items.update(
        product.id.toString(),
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id.toString(),
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
    } else {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }
}
