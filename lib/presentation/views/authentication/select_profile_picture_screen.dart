import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectProfilePictureScreen extends StatefulWidget {
  const SelectProfilePictureScreen({super.key});

  @override
  _SelectProfilePictureScreenState createState() =>
      _SelectProfilePictureScreenState();
}

class _SelectProfilePictureScreenState
    extends State<SelectProfilePictureScreen> {
  File? _imageFile;
  Uint8List? _webImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
        });

        // Save image bytes as base64 string
        prefs.setString('profile_image_web', base64Encode(bytes));
        prefs.remove('profile_image_path');
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _webImage = null;
        });
        // Save file path
        prefs.setString('profile_image_path', picked.path);
        prefs.remove('profile_image_web');
      }
    }
  }

  void _showPickOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Choose from Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _skipProfileSetup() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<String?> _uploadImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      UploadTask uploadTask;

      if (kIsWeb && _webImage != null) {
        uploadTask = storageRef.putData(_webImage!);
      } else if (_imageFile != null) {
        uploadTask = storageRef.putFile(_imageFile!);
      } else {
        return null;
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> _saveImageUrlToFirestore(String url) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'profileImage': url,
    }, SetOptions(merge: true));
  }

  void _saveAndContinue() async {
    if (_imageFile != null || _webImage != null) {
      final url = await _uploadImage();
      if (url != null) {
        await _saveImageUrlToFirestore(url);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppColors.blue;
    final screenWidth = MediaQuery.of(context).size.width;

    Widget avatar;
    if (_webImage != null) {
      avatar = CircleAvatar(
        radius: 70,
        backgroundImage: MemoryImage(_webImage!),
      );
    } else if (_imageFile != null) {
      avatar = CircleAvatar(
        radius: 70,
        backgroundImage: FileImage(_imageFile!),
      );
    } else {
      avatar = CircleAvatar(
        radius: 70,
        backgroundColor: themeColor.withOpacity(0.1),
        child: Icon(Icons.person, size: 60, color: Colors.grey),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          "Setup Profile",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              avatar,
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showPickOptionsDialog,
                icon: Icon(Icons.upload),
                label: Text("Upload Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Save & Continue",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: _skipProfileSetup,
                child: Text(
                  "Skip",
                  style: TextStyle(color: themeColor, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
