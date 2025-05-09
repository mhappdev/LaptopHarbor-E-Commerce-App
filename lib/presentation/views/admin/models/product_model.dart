import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String brandName;
  final String laptopName;
  final String shortDesc;
  final String longDesc;
  final double price;
  final String category;
  final List<String> imageUrls; // ✅ multiple images
  final double rating;
  final int numReviews;
  final Map<String, String> specifications;
  final DateTime timestamp;

  Product({
    required this.id,
    required this.brandName,
    required this.laptopName,
    required this.shortDesc,
    required this.longDesc,
    required this.price,
    required this.imageUrls,
    required this.rating,
    required this.numReviews,
    required this.category,
    required this.specifications,
    required this.timestamp,
  });

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      brandName: data['brandName'] ?? 'No brand name',
      laptopName: data['laptopName'] ?? 'No laptop name',
      shortDesc: data['shortDesc'] ?? 'No short description',
      longDesc: data['longDesc'] ?? 'No long description',
      price: (data['price'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []), // ✅ updated
      rating: (data['rating'] ?? 0).toDouble(),
      numReviews: data['numReviews'] ?? 0,
      category: data['category'] ?? 'General',
      specifications: Map<String, String>.from(data['specifications'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brandName': brandName,
      'laptopName': laptopName,
      'shortDesc': shortDesc,
      'longDesc': longDesc,
      'price': price,
      'imageUrls': imageUrls, // ✅ updated
      'rating': rating,
      'numReviews': numReviews,
      'category': category,
      'specifications': specifications,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
