import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/utils/toast_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isImageUploading = false;
  String? _originalEmail;
  String? _profileImageUrl;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. First try to get from Firestore (primary source)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _profileImageUrl = data['profileImageUrl'];
        _originalEmail = user.email;

        // Save to SharedPreferences for offline access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', _nameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('phone', _phoneController.text);
        if (_profileImageUrl != null) {
          await prefs.setString('profileImageUrl', _profileImageUrl!);
        }
      } else {
        // 2. Fallback to SharedPreferences if no Firestore doc exists
        final prefs = await SharedPreferences.getInstance();
        _nameController.text = prefs.getString('name') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _phoneController.text = prefs.getString('phone') ?? '';
        _profileImageUrl = prefs.getString('profileImageUrl');
        _originalEmail = user.email;
      }
    } catch (e) {
      ToastMsg.showToastMsg('Error loading profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      ToastMsg.showToastMsg('Error picking image: ${e.toString()}');
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImageFile == null) return;

    setState(() => _isImageUploading = true);

    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/diu1cxyph/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'profiles'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedImageFile!.path,
        ));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(responseData);
        final imageUrl = jsonMap['secure_url'] ?? jsonMap['url'];

        // Update in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profileImageUrl': imageUrl});
        }

        // Update locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageUrl', imageUrl);

        setState(() {
          _profileImageUrl = imageUrl;
          _selectedImageFile = null;
        });

        ToastMsg.showToastMsg('Profile picture updated successfully!');
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      ToastMsg.showToastMsg('Error uploading image: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isImageUploading = false);
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    String password = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authentication Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('For security, please enter your current password:'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(password),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (user != null) {
        final uid = user.uid;
        bool emailChanged = newEmail != _originalEmail;

        // Update user data including profile image URL if it exists
        final updateData = {
          'name': name,
          'email': newEmail,
          'phone': phone,
          if (_profileImageUrl != null) 'profileImageUrl': _profileImageUrl,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update(updateData);

        // Update display name in Firebase Auth
        await user.updateDisplayName(name);

        // Handle email update if changed
        if (emailChanged) {
          try {
            await user.verifyBeforeUpdateEmail(newEmail);
            ToastMsg.showToastMsg(
                'Verification email sent to your new address. Please verify.');
          } on FirebaseAuthException catch (e) {
            if (e.code == 'requires-recent-login') {
              final password = await _showPasswordDialog();
              if (password == null) {
                throw Exception('Reauthentication cancelled');
              }

              final credential = EmailAuthProvider.credential(
                email: user.email!,
                password: password,
              );

              await user.reauthenticateWithCredential(credential);
              await user.verifyBeforeUpdateEmail(newEmail);
              ToastMsg.showToastMsg(
                  'Verification email sent to your new address. Please verify.');
            } else {
              throw e;
            }
          }
        }

        // Update local storage
        await prefs.setString('name', name);
        await prefs.setString('email', newEmail);
        await prefs.setString('phone', phone);
        if (_profileImageUrl != null) {
          await prefs.setString('profileImageUrl', _profileImageUrl!);
        }

        ToastMsg.showToastMsg('Profile updated successfully!');
        if (!mounted) return;
        Navigator.pushNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error updating profile: ${e.message}';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use by another account.';
      }
      ToastMsg.showToastMsg(errorMessage);
    } catch (e) {
      ToastMsg.showToastMsg('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.blue;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _isImageUploading
                                ? Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _getProfileImage(),
                                  ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: _isImageUploading ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor,
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Rest of your form fields...
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration("Name", Icons.person),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration("Email", Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration("Phone", Icons.phone),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10 || value.length > 15) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Save",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    } else if (_profileImageUrl != null) {
      return NetworkImage(_profileImageUrl!);
    }
    return const AssetImage('assets/images/default_avatar.png');
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.blue),
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
