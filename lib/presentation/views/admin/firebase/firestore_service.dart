import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbor/data/models/product_model.dart';
import 'package:laptop_harbor/presentation/views/admin/firebase/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔁 Get Products Stream
  Stream<List<Product>> getProductsStream() {
    return _db
        .collection('products')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ✅ Add Product with multiple images
  Future<void> addProduct(Product product) async {
    await _db.collection('products').doc(product.id).set(product.toMap());
  }

  // ❌ Delete Product
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // ✏️ Update Product
  Future<void> updateProduct(Product product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  // 💬 Add Review
  Future<void> addReview(String productId, Review review) async {
    await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .add(review.toMap());
  }

  // 🔄 Get Reviews
  Stream<List<Review>> getReviews(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Review.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
