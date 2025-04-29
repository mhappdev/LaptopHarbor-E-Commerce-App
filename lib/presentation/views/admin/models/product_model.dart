class Product {
  final String id;
  final String brandName;
  final String laptopName;
  final String shortDesc;
  final String longDesc;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.brandName,
    required this.laptopName,
    required this.shortDesc,
    required this.longDesc,
    required this.price,
    required this.imageUrl,
  });

  // Factory constructor to create a Product object from Firestore data
  factory Product.fromFirestore(Map<String, dynamic> firestoreData, String id) {
    return Product(
      id: id,
      brandName: firestoreData['brandName'] ??
          'No brand name', // Default value if null
      laptopName: firestoreData['laptopName'] ??
          'No brand name', // Default value if null
      shortDesc: firestoreData['shortDesc'] ??
          'No short description available', // Default value if null
      longDesc: firestoreData['longDesc'] ??
          'No long description available', // Default value if null
      price: firestoreData['price']?.toDouble() ??
          0.0, // Handle null or invalid price gracefully
      imageUrl: firestoreData['imageUrl'] ??
          'https://via.placeholder.com/150', // Default image URL
    );
  }

  // Convert the Product object to a map to send to Firestore
  Map<String, dynamic> toMap() {
    return {
      'brandName': brandName,
      'laptopName': laptopName,
      'shortDesc': shortDesc,
      'longDesc': longDesc,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
