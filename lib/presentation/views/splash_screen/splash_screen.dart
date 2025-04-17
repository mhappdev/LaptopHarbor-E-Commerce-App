import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/core/images_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Instance of splash services

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // CHECK LOGIN STATUS
  // This function checks if the user is logged in or not and navigates accordingly
  void _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 2)); // simulate splash time

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ✅ User already logged in
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 👣 Continue to onboarding or auth
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 1;
    final height = MediaQuery.sizeOf(context).height * 1;

    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Center(
        child: SvgPicture.asset(
          ImagesPath.appLogo,
          width: width * 0.25,
          height: height * 0.25,
        ),
      ),
    );
  }
}
