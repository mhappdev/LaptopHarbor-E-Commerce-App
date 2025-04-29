import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop_harbor/presentation/views/admin/firebase/firestore_service.dart';
import 'package:laptop_harbor/presentation/views/admin/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final brandController = TextEditingController();
  final laptopNameController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();
  final priceController = TextEditingController();
  String? base64Image;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => base64Image = base64Encode(bytes));
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brandName: brandController.text.trim(),
      laptopName: laptopNameController.text.trim(),
      shortDesc: shortDescController.text.trim(),
      longDesc: longDescController.text.trim(),
      price: double.tryParse(priceController.text.trim()) ?? 0.0,
      imageUrl: base64Image!,
    );

    await FirestoreService().addProduct(product);

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
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
        title: const Text('Add Product'),
        backgroundColor: Colors.white,
        elevation: 0, // No shadow on AppBar
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Name Input
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: brandController,
                        decoration: _inputDecoration("Brand Name"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Brand name is required';
                          return null;
                        },
                      ),
                    ),
                    // Brand Name
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: laptopNameController,
                        decoration: _inputDecoration("Laptop Name"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Laptop name is required';
                          return null;
                        },
                      ),
                    ),
                    // Short Description Input
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: shortDescController,
                        decoration: _inputDecoration("Short Description"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Short description is required';
                          return null;
                        },
                      ),
                    ),
                    // Long Description Input
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: longDescController,
                        maxLines: 3,
                        decoration: _inputDecoration("Long Description"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Long description is required';
                          return null;
                        },
                      ),
                    ),
                    // Price Input
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("Price"),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Price is required';
                          if (double.tryParse(v.trim()) == null)
                            return 'Enter a valid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image Picker Button
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, color: Colors.white),
                      label: const Text('Pick Product Image',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .blueAccent, // Stylish color for image picker button
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                            color: Colors.blueAccent, width: 1),
                        elevation: 4, // Adding shadow for a modern look
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Add Product Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        label: const Text(
                          "Add Product",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xFF4CAF50), // Professional Green color for Add Product button
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5, // Adding shadow
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
