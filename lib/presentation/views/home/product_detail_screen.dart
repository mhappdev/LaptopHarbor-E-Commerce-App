import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:laptop_harbor/data/models/product_model.dart';
import 'package:laptop_harbor/presentation/providers/cart_provider.dart';
import 'package:laptop_harbor/presentation/views/order/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // For better date formatting

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  double _averageRating = 0;
  int _totalReviews = 0;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('userreviews')
          .where('productId', isEqualTo: widget.product.id)
          .orderBy('timestamp', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        List<Map<String, dynamic>> reviews = [];

        for (var doc in reviewsSnapshot.docs) {
          final reviewData = doc.data();
          totalRating += reviewData['rating'] ?? 0;

          try {
            final orderQuery = await FirebaseFirestore.instance
                .collection('orders')
                .where('orderId', isEqualTo: reviewData['orderId'])
                .limit(1)
                .get()
                .timeout(const Duration(seconds: 5));

            String customerName = 'Anonymous';
            if (orderQuery.docs.isNotEmpty) {
              customerName =
                  orderQuery.docs.first.data()['customerName'] ?? 'Anonymous';
            }

            reviews.add({
              'rating': reviewData['rating'],
              'review': reviewData['review'],
              'customerName': customerName,
              'timestamp': reviewData['timestamp'],
            });
          } catch (e) {
            // If order lookup fails, still add the review with anonymous name
            reviews.add({
              'rating': reviewData['rating'],
              'review': reviewData['review'],
              'customerName': 'Anonymous',
              'timestamp': reviewData['timestamp'],
            });
            print('Error fetching order details: $e');
          }
        }

        setState(() {
          _averageRating = totalRating / reviewsSnapshot.docs.length;
          _totalReviews = reviewsSnapshot.docs.length;
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      } else {
        setState(() {
          _isLoadingReviews = false;
          _reviews = [];
          _totalReviews = 0;
          _averageRating = 0;
        });
      }
    } on FirebaseException catch (e) {
      print('Firestore error fetching reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
      // Show error to user if needed
    } on TimeoutException catch (e) {
      print('Timeout fetching reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
      // Show timeout error to user
    } catch (e) {
      print('Unexpected error fetching reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.product.laptopName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.blue,
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSlider(),
              _buildImageIndicators(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand and Price row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.product.brandName,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Product name
                    Text(
                      widget.product.laptopName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating and review count with stars
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${_averageRating.toStringAsFixed(1)} ($_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'})',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity selector
                    Row(
                      children: [
                        const Text('Quantity:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                },
                              ),
                              Text('$_quantity',
                                  style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description section
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.longDesc,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Specifications section
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.product.specifications.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Customer Reviews section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Customer Reviews',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_totalReviews > 0)
                          TextButton(
                            onPressed: () {
                              // Show all reviews in a dialog
                              _showAllReviewsDialog();
                            },
                            child: Text(
                              'View all ($_totalReviews)',
                              style: TextStyle(
                                color: AppColors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Reviews loading indicator
                    if (_isLoadingReviews)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_reviews.isEmpty)
                      const Text('No reviews yet. Be the first to review!')
                    else
                      Column(
                        children: [
                          // Show only the first 2 reviews in the main view
                          ..._reviews
                              .take(2)
                              .map((review) => _buildReviewCard(review)),
                          if (_reviews.length > 2)
                            TextButton(
                              onPressed: () {
                                _showAllReviewsDialog();
                              },
                              child: Text(
                                'Show all $_totalReviews reviews',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    cartProvider.addToCart(widget.product, _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Added ${widget.product.laptopName} to cart'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    cartProvider.addToCart(widget.product, _quantity);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )));
  }

  void _showAllReviewsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Reviews ($_totalReviews)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildReviewCard(_reviews[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            aspectRatio: 16 / 9,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          items: widget.product.imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1}/${widget.product.imageUrls.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.product.imageUrls.map((url) {
        int index = widget.product.imageUrls.indexOf(url);
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                _currentImageIndex == index ? AppColors.blue : Colors.grey[300],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.blue.withOpacity(0.2),
                  child: Text(
                    review['customerName']
                        .toString()
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(color: AppColors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['customerName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 16,
                            color: index < (review['rating'] as int)
                                ? Colors.amber
                                : Colors.grey[300],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review['review'],
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            if (review['timestamp'] != null)
              Text(
                _formatTimestamp(review['timestamp']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMMM d, y - h:mm a').format(date);
  }
}
