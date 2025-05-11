import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Uint8List? webImageBytes;
  File? imageFile;
  String userName = 'No Name';
  String userEmail = 'No Email';
  String? userPhone;
  String? profileImageUrl;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    loadUserDetails();
    loadProfileImage();
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('profileImageUrl');
    setState(() {
      profileImageUrl = url;
    });
  }

  Future<void> loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'No Name';
      userEmail = prefs.getString('email') ?? 'No Email';
      userPhone = prefs.getString('phone');
      
      if (kIsWeb) {
        final base64Image = prefs.getString('profile_image_web');
        if (base64Image != null) {
          webImageBytes = base64Decode(base64Image);
        }
      } else {
        final path = prefs.getString('profile_image_path');
        if (path != null) {
          imageFile = File(path);
        }
      }
    });
  }

  Future<void> signOutUser(BuildContext context) async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      // Clear SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to login screen and remove all routes
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', 
          (Route<dynamic> route) => false
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      backgroundColor: AppColors.blue,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.08,
                      backgroundImage: webImageBytes != null
                          ? MemoryImage(webImageBytes!)
                          : imageFile != null
                              ? FileImage(imageFile!)
                              : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                                  ? NetworkImage(profileImageUrl!)
                                  : const AssetImage('assets/images/default_avatar.png'))
                                      as ImageProvider,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),

                // Drawer Items
                buildDrawerItem(context, Icons.person, "My Profile", () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my-profile');
                }),
                buildDrawerItem(context, Icons.lock_reset, "Change Password", () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/change-password');
                }),
                buildDrawerItem(context, Icons.mail_outline, "Contact Us", () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/contact-form');
                }),
                buildDrawerItem(context, Icons.help_outline, "Help & FAQs", () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/faqs');
                }),

                // Logout Button with loading indicator
                Column(
                  children: [
                    ListTile(
                      leading: _isSigningOut
                          ? SizedBox(
                              width: screenWidth * 0.065,
                              height: screenWidth * 0.065,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: screenWidth * 0.065,
                            ),
                      title: Text(
                        _isSigningOut ? "Signing out..." : "Log Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      onTap: _isSigningOut ? null : () => signOutUser(context),
                    ),
                    const Divider(color: Colors.white24, thickness: 1),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.white, size: screenWidth * 0.065),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
            ),
          ),
          onTap: onTap,
        ),
        const Divider(color: Colors.white24, thickness: 1),
      ],
    );
  }
}