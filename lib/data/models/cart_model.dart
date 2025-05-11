import 'package:laptop_harbor/data/models/product_model.dart';

class CartItem {
  final Product product;
  int quantity;
  double get totalPrice => product.price * quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }
}