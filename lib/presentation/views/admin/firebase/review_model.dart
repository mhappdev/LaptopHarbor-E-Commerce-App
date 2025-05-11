import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String username;
  final double rating;
  final String reviewText;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.userId,
    required this.username,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
  });

  factory Review.fromFirestore(Map<String, dynamic> data, String id) {
    return Review(
      id: id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toDouble(),
      reviewText: data['reviewText'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'rating': rating,
      'reviewText': reviewText,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
