import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop_harbor/presentation/views/admin/firebase/firestore_service.dart';
import 'package:laptop_harbor/presentation/views/admin/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController brandController,
      laptopNameController,
      shortDescController,
      longDescController,
      priceController;
  String? base64Image;

  @override
  void initState() {
    super.initState();
    brandController = TextEditingController(text: widget.product.brandName);
    laptopNameController =
        TextEditingController(text: widget.product.laptopName);
    shortDescController = TextEditingController(text: widget.product.shortDesc);
    longDescController = TextEditingController(text: widget.product.longDesc);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    base64Image = widget.product.imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => base64Image = base64Encode(bytes));
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || base64Image == null) return;

    final updatedProduct = Product(
      id: widget.product.id,
      brandName: brandController.text,
      laptopName: laptopNameController.text,
      shortDesc: shortDescController.text,
      longDesc: longDescController.text,
      price: double.parse(priceController.text),
      imageUrl: base64Image!,
    );

    await FirestoreService().updateProduct(updatedProduct);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageData;
    if (base64Image != null) {
      try {
        imageData = base64Decode(base64Image!);
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview and pick image button
              if (imageData != null)
                Container(
                  alignment: Alignment.center,
                  child: Image.memory(imageData, height: 200),
                ),
              const SizedBox(height: 20), // Spacing added here
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Colors.white),
                label: const Text('Change Image',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
              const SizedBox(
                  height: 20), // Added spacing between button and text fields
              _buildTextField(brandController, 'Brand Name', false),
              const SizedBox(height: 16),
              _buildTextField(laptopNameController, 'Laptop Name', false),
              const SizedBox(height: 16),
              _buildTextField(shortDescController, 'Short Description', false),
              const SizedBox(height: 16),
              _buildTextField(longDescController, 'Long Description', false,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(priceController, 'Price', true),
              const SizedBox(height: 30), // More spacing before the Save button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save Changes',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 5,
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
      TextEditingController controller, String label, bool isNumeric,
      {int? maxLines}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'This field is required';
        if (isNumeric && double.tryParse(v.trim()) == null)
          return 'Please enter a valid number';
        return null;
      },
    );
  }
}
