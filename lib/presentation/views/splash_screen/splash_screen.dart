import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/core/images_path.dart';
import 'package:laptop_harbor/presentation/views/on_boarding/on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      (Duration(seconds: 4)),
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OnBoardingScreen()),
        );
      },
    );
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
