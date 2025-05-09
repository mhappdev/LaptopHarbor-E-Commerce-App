import 'package:flutter/material.dart';
import 'package:laptop_harbor/presentation/views/admin/models/product_model.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  bool isInWishlist(Product product) {
    return _wishlist.contains(product);
  }

  void toggleWishlist(Product product) {
    if (isInWishlist(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }
}
