import 'package:flutter/material.dart';
import 'package:laptop_harbor/presentation/views/admin/firebase/firestore_service.dart';
import 'package:laptop_harbor/presentation/views/admin/models/product_model.dart';
import 'package:laptop_harbor/presentation/views/admin/screens/add_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Product Details'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: _isEditing ? _buildEditForm() : _buildDetailsView(),
    );
  }

  Widget _buildDetailsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: _product.imageUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.network(
                    _product.imageUrls[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_product.brandName} ${_product.laptopName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            '\$${_product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(_product.longDesc),
          const SizedBox(height: 20),
          Text(
            'Specifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          ..._product.specifications.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(entry.value),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rating: ${_product.rating.toStringAsFixed(1)} (${_product.numReviews} reviews)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return AddProductScreen(
      initialProduct: _product,
      onProductUpdated: (updatedProduct) {
        setState(() {
          _product = updatedProduct;
          _isEditing = false;
        });
      },
    );
  }

  Future<void> _saveChanges() async {
    try {
      await FirestoreService().updateProduct(_product);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully')),
      );
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: ${e.toString()}')),
      );
    }
  }
}
