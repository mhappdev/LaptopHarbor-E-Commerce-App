import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/presentation/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class Wishlist extends StatelessWidget {
  const Wishlist({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My WishList",
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: wishlist.wishlist.isEmpty
          ? const Center(child: Text('Your wishlist is empty.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: wishlist.wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist.wishlist[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: Image.network(
                      product.imageUrls.first,
                      width: 60,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(product.laptopName,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        wishlist.toggleWishlist(product);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
