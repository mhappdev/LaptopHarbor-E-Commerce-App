import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectProfilePictureScreen extends StatefulWidget {
  const SelectProfilePictureScreen({super.key});

  @override
  State<SelectProfilePictureScreen> createState() =>
      _SelectProfilePictureScreenState();
}

class _SelectProfilePictureScreenState
    extends State<SelectProfilePictureScreen> {
  File? _imageFile;
  String? _ImageUrl;
  final Color primaryColor = const Color(0xff037EEE);
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadToImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isUploading = true;
    });

    final url = Uri.parse('https://api.cloudinary.com/v1_1/diu1cxyph/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'profiles'
      ..files.add(await http.MultipartFile.fromPath('file', _imageFile!.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        _ImageUrl = jsonMap['url'];
      });

      // Save image URL to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImageUrl', _ImageUrl!);

      // Redirect to /home
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed. Please try again.')),
      );
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = 130;

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Profile Picture'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: _imageFile != null
                  ? CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundImage: FileImage(_imageFile!),
                    )
                  : CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt),
              label: Text('Take a Picture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library),
              label: Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed:
                  _imageFile == null || _isUploading ? null : _uploadToImage,
              icon: _isUploading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.save),
              label: Text(_isUploading ? 'Uploading...' : 'Save and Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: Size.fromHeight(50),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text('Skip for now')),
            const SizedBox(height: 20),
            if (_ImageUrl != null)
              Column(
                children: [
                  Text('Uploaded Image Preview:'),
                  const SizedBox(height: 8),
                  Image.network(_ImageUrl!),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
