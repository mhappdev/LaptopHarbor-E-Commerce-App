import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/core/images_path.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -height * 0.15,
            right: -width * 0.2,
            child: Container(
              width: width * 0.7,
              height: width * 0.7,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -height * 0.25,
            left: -width * 0.2,
            child: Container(
              width: width * 0.8,
              height: width * 0.8,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with hero animation
                  Hero(
                    tag: 'app-logo',
                    child: SvgPicture.asset(
                      ImagesPath.appLogo,
                      width: width * 0.35,
                      height: width * 0.35,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Description text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.15),
                    child: Text(
                      "Your premium destination for the latest laptops\nand tech accessories",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login Button
                  Material(
                    borderRadius: BorderRadius.circular(30),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      splashColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        width: width * 0.7,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Sign Up Button
                  Material(
                    borderRadius: BorderRadius.circular(30),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      splashColor: Colors.black.withOpacity(0.2),
                      highlightColor: Colors.black.withOpacity(0.1),
                      child: Container(
                        width: width * 0.7,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'LeagueSpartan',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
