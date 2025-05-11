import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:laptop_harbor/presentation/views/admin/firebase/firestore_service.dart';
import 'package:laptop_harbor/data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final Product? initialProduct;
  final Function(Product)? onProductUpdated;

  const AddProductScreen({
    Key? key,
    this.initialProduct,
    this.onProductUpdated,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController laptopNameController = TextEditingController();
  final TextEditingController shortDescController = TextEditingController();
  final TextEditingController longDescController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController numReviewsController = TextEditingController();

  List<XFile> images = [];
  List<String> existingImageUrls = [];
  bool _isLoading = false;
  final Map<String, String> specifications = {};

  final TextEditingController ramController = TextEditingController();
  final TextEditingController ssdController = TextEditingController();
  final TextEditingController hddController = TextEditingController();
  final TextEditingController processorController = TextEditingController();

  final String cloudinaryUrl =
      "https://api.cloudinary.com/v1_1/diu1cxyph/image/upload";
  final String cloudinaryUploadPreset = "profiles";

  @override
  void initState() {
    super.initState();

    if (widget.initialProduct != null) {
      final product = widget.initialProduct!;
      brandController.text = product.brandName;
      laptopNameController.text = product.laptopName;
      shortDescController.text = product.shortDesc;
      longDescController.text = product.longDesc;
      priceController.text = product.price.toString();
      categoryController.text = product.category;
      ratingController.text = product.rating.toString();
      numReviewsController.text = product.numReviews.toString();
      existingImageUrls = product.imageUrls;

      ramController.text = product.specifications['RAM'] ?? '';
      ssdController.text = product.specifications['SSD'] ?? '';
      hddController.text = product.specifications['HDD'] ?? '';
      processorController.text = product.specifications['Processor'] ?? '';
    }
  }

  Future<void> _pickImages() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1440,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          images.addAll(pickedFiles);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: ${e.toString()}')),
      );
    }
  }

  Future<void> _removeImage(int index, bool isExisting) async {
    setState(() {
      if (isExisting) {
        existingImageUrls.removeAt(index);
      } else {
        images.removeAt(index);
      }
    });
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    for (var image in images) {
      try {
        Uint8List bytes = await image.readAsBytes();

        var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
          ..fields['upload_preset'] = cloudinaryUploadPreset
          ..files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['secure_url'] != null) {
            imageUrls.add(result['secure_url']);
          } else {
            throw Exception('Failed to get image URL from Cloudinary response');
          }
        } else {
          throw Exception(
              'Failed to upload image. Status code: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Image upload error: ${e.toString()}');
      }
    }

    return imageUrls;
  }

  Widget _buildImagePreview() {
    final allImages = [
      ...existingImageUrls.map((url) => _ImageItem(url: url, isExisting: true)),
      ...images.map((file) => _ImageItem(file: file, isExisting: false)),
    ];

    if (allImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected Images:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              final item = allImages[index];
              return FutureBuilder<Uint8List>(
                future: item.file != null ? item.file!.readAsBytes() : null,
                builder: (context, snapshot) {
                  if (item.file != null &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: item.file != null
                                ? DecorationImage(
                                    image: MemoryImage(snapshot.data!),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(item.url!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                _removeImage(index, item.isExisting),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (images.isEmpty && existingImageUrls.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    specifications['RAM'] = ramController.text.trim();
    specifications['SSD'] = ssdController.text.trim();
    specifications['HDD'] = hddController.text.trim();
    specifications['Processor'] = processorController.text.trim();

    setState(() => _isLoading = true);

    try {
      List<String> newImageUrls = [];
      if (images.isNotEmpty) {
        newImageUrls = await _uploadImages();
      }
      final allImageUrls = [...existingImageUrls, ...newImageUrls];

      final product = Product(
        id: widget.initialProduct?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        brandName: brandController.text.trim(),
        laptopName: laptopNameController.text.trim(),
        shortDesc: shortDescController.text.trim(),
        longDesc: longDescController.text.trim(),
        price: double.tryParse(priceController.text.trim()) ?? 0.0,
        imageUrls: allImageUrls,
        rating: double.tryParse(ratingController.text.trim()) ?? 0.0,
        numReviews: int.tryParse(numReviewsController.text.trim()) ?? 0,
        category: categoryController.text.trim(),
        specifications: specifications,
        timestamp: widget.initialProduct?.timestamp ?? DateTime.now(),
      );

      if (widget.initialProduct != null) {
        await FirestoreService().updateProduct(product);
        if (!mounted) return;
        widget.onProductUpdated?.call(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      } else {
        await FirestoreService().addProduct(product);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black54, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialProduct != null ? 'Edit Product' : 'Add Product'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildImagePreview(),
                    _buildTextField(brandController, 'Brand Name'),
                    _buildTextField(laptopNameController, 'Laptop Name'),
                    _buildTextField(shortDescController, 'Short Description'),
                    _buildTextField(longDescController, 'Long Description',
                        maxLines: 3),
                    _buildTextField(
                      priceController,
                      'Price',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Price is required';
                        if (double.tryParse(v.trim()) == null)
                          return 'Enter a valid price';
                        return null;
                      },
                    ),
                    _buildTextField(categoryController, 'Category'),
                    const SizedBox(height: 16),
                    _buildTextField(ramController, 'RAM (e.g., 16GB)'),
                    _buildTextField(ssdController, 'SSD (e.g., 512GB)'),
                    _buildTextField(hddController, 'HDD (e.g., 1TB)'),
                    _buildTextField(
                        processorController, 'Processor (e.g., Intel Core i7)'),
                    const SizedBox(height: 16),
                    _buildTextField(ratingController, 'Rating (0.0 - 5.0)',
                        keyboardType: TextInputType.number, validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final rating = double.tryParse(v.trim());
                      if (rating == null || rating < 0 || rating > 5) {
                        return 'Rating must be between 0.0 and 5.0';
                      }
                      return null;
                    }),
                    _buildTextField(numReviewsController, 'Number of Reviews',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.image),
                      label: const Text('Add Product Images'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          widget.initialProduct != null
                              ? 'Update Product'
                              : 'Add Product',
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
        validator: validator ??
            (v) {
              if (v == null || v.trim().isEmpty) return '$label is required';
              return null;
            },
      ),
    );
  }
}

class _ImageItem {
  final String? url;
  final XFile? file;
  final bool isExisting;

  _ImageItem({
    this.url,
    this.file,
    required this.isExisting,
  }) : assert(url != null || file != null);
}
