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

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'No Name';
      userEmail = prefs.getString('email') ?? 'No Email';
      userPhone = prefs.getString('phone'); // May be null

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

  // SIGNOUT USER AND ALSO REMOVE DATA FROM SHARED PREFERENCES
  Future<void> signOutUser(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      shape: RoundedRectangleBorder(
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
                              : AssetImage('assets/user.jpg') as ImageProvider,
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
                  Navigator.pushNamed(context, '/my-profile');
                }),
                buildDrawerItem(context, Icons.shopping_bag, "My Orders", () {
                  Navigator.pushNamed(context, '/orders');
                }),
                buildDrawerItem(context, Icons.location_on, "Change Password",
                    () {
                  Navigator.pushNamed(context, '/change-password');
                }),
                buildDrawerItem(context, Icons.credit_card, "Payment Methods",
                    () {
                  Navigator.pushNamed(context, '/payments');
                }),
                buildDrawerItem(context, Icons.mail_outline, "Contact Us", () {
                  Navigator.pushNamed(context, '/contact');
                }),
                buildDrawerItem(context, Icons.help_outline, "Help & FAQs", () {
                  Navigator.pushNamed(context, '/help');
                }),
                buildDrawerItem(context, Icons.settings, "Settings", () {
                  Navigator.pushNamed(context, '/settings');
                }),
                buildDrawerItem(context, Icons.logout, "Log Out", () {
                  signOutUser(context);
                }),
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
          onTap: () {
            Navigator.pop(context); // Close drawer
            onTap(); // Perform action
          },
        ),
        Divider(color: Colors.white24, thickness: 1),
      ],
    );
  }
}
