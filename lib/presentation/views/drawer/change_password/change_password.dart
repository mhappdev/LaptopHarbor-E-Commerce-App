import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/utils/toast_msg.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  final FocusNode _currentPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  double _bottomPadding = 20.0;

  @override
  void initState() {
    super.initState();
    // Add listeners for keyboard visibility changes
    _currentPasswordFocus.addListener(_onFocusChange);
    _newPasswordFocus.addListener(_onFocusChange);
    _confirmPasswordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_currentPasswordFocus.hasFocus ||
        _newPasswordFocus.hasFocus ||
        _confirmPasswordFocus.hasFocus) {
      setState(
          () => _bottomPadding = 50.0); // Extra padding when keyboard is open
    } else {
      setState(() => _bottomPadding = 20.0); // Normal padding
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<bool> _verifyCurrentPassword() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      // Get user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return false;

      final storedPassword = userDoc.data()?['password'] as String?;
      if (storedPassword == null) return false;

      return storedPassword == _currentPasswordController.text.trim();
    } catch (e) {
      debugPrint('Error verifying password: $e');
      return false;
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First verify the current password matches the one in Firestore
      final isCurrentPasswordValid = await _verifyCurrentPassword();
      if (!isCurrentPasswordValid) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Current password is incorrect',
        );
      }

      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      if (user == null || email == null) {
        throw Exception("User not authenticated");
      }

      // 1. Reauthenticate user (still needed for Firebase Auth)
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Update password
      await user.updatePassword(_newPasswordController.text.trim());

      // 3. Update password in Firestore as well
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'password': _newPasswordController.text.trim()});

      // Success
      ToastMsg.showToastMsg("Password changed successfully!");
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Password change failed";
      if (e.code == 'wrong-password') {
        errorMessage = "Current password is incorrect";
      } else if (e.code == 'weak-password') {
        errorMessage = "New password is too weak (min 6 characters)";
      } else {
        errorMessage = e.message ?? errorMessage;
      }
      ToastMsg.showToastMsg(errorMessage);
    } catch (e) {
      ToastMsg.showToastMsg("An error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: _bottomPadding,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Create a new password",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your new password must be different from previous passwords.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Current Password
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrentPassword,
                  focusNode: _currentPasswordFocus,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(() =>
                          _obscureCurrentPassword = !_obscureCurrentPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your current password";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // New Password
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  focusNode: _newPasswordFocus,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a new password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  focusNode: _confirmPasswordFocus,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your new password";
                    }
                    if (value != _newPasswordController.text) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Update Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
