import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:laptop_harbor/core/app_colors.dart';
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
  String? _imageUrl;
  final Color primaryColor = AppColors.blue;
  bool _isUploading = false;
  double _uploadProgress = 0;
  bool _hasError = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _hasError = false; // Reset error state when a new image is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _uploadToImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _hasError = false; // Reset error state when upload starts
    });

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/diu1cxyph/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'profiles'
        ..files
            .add(await http.MultipartFile.fromPath('file', _imageFile!.path));

      // Create a completer to handle the response
      final completer = Completer<http.Response>();
      final responseStream = await request.send();
      final totalBytes = responseStream.contentLength ?? 0;
      int receivedBytes = 0;

      // Collect the response data
      final chunks = <List<int>>[];
      responseStream.stream.listen(
        (List<int> chunk) {
          // Update progress
          receivedBytes += chunk.length;
          if (mounted) {
            setState(() {
              _uploadProgress = totalBytes > 0 ? receivedBytes / totalBytes : 0;
            });
          }
          // Collect chunks for the response
          chunks.add(chunk);
        },
        onDone: () async {
          // Combine all chunks into a single response
          final response = http.Response.bytes(
            chunks.expand((x) => x).toList(),
            responseStream.statusCode,
            request: responseStream.request,
            headers: responseStream.headers,
            isRedirect: responseStream.isRedirect,
            persistentConnection: responseStream.persistentConnection,
            reasonPhrase: responseStream.reasonPhrase,
          );
          completer.complete(response);
        },
        onError: (e) {
          completer.completeError(e);
        },
      );

      // Wait for the response
      final response =
          await completer.future.timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _imageUrl = jsonMap['secure_url'] ?? jsonMap['url'];
          });
        }

        // Save image URL to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageUrl', _imageUrl!);

        // Redirect to /home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload timed out. Please try again.')),
        );
      }
      setState(() {
        _hasError = true; // Show error on failure
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
      setState(() {
        _hasError = true; // Show error on failure
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = 130;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Profile Picture',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
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
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.grey),
                      ),
              ),
              const SizedBox(height: 24),
              // Upload progress indicator
              _hasError
                  ? AnimatedOpacity(
                      opacity: _hasError ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        width: double.infinity,
                        height: 4,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            'Error occurred!',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    )
                  : LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    _isUploading ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'Take a Picture',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed:
                    _isUploading ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(50),
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
                    : const Icon(Icons.save),
                label:
                    Text(_isUploading ? 'Uploading...' : 'Save and Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
