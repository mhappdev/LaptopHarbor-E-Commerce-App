import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/core/images_path.dart';
import 'package:laptop_harbor/presentation/widgets/custom_button.dart';
import 'package:laptop_harbor/presentation/widgets/onboarding_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController controller = PageController();
  bool isLastPage = false;
  final pages = [
    // 1st screen
    OnboardingPage(
      imagePath: ImagesPath.onBoardingImgTwo,
      title: 'Purchase Online !!',
      description:
          "Explore a wide range of premium laptops and accessories. Compare specs, check reviews, and shop with confidence—all in one place.",
    ),
    // 2nd screen
    OnboardingPage(
      imagePath: ImagesPath.onBoardingImgThree,
      title: 'Track Order !!',
      description:
          'Stay updated every step of the way. Track your orders in real-time and get notified instantly.',
    ),
    // 3rd Screen
    OnboardingPage(
      imagePath: ImagesPath.onBoardingImgThree,
      title: 'Get Your Order !!',
      description:
          'Enjoy fast and reliable delivery right to your doorstep. Your tech essentials, delivered safely and securely.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            itemBuilder: (context, index) {
              return pages[index];
            },
            itemCount: 3,
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
          ),
          // SKIP BUTTON
          Positioned(
            top: 20,
            right: 20,
            child: isLastPage
                ? SizedBox.shrink() // Hide Skip Button on last page
                : TextButton(
                    onPressed: () {
                      controller.jumpToPage(2);
                    },
                    child: Text(
                      "Skip >",
                      style: TextStyle(
                        fontFamily: 'LeagueSpartan',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
          ),
          // DOTS AND NEXT BUTTON
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    dotColor: AppColors.dotColor,
                    activeDotColor: // 💨 Highlights the current page.
                        AppColors.blue,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                // NEXT / GET STARTED BUTTON
                SizedBox(
                  height: 32,
                ),
                isLastPage
                    ? CustomButton(
                        width: (133 / 375) * MediaQuery.of(context).size.width,
                        height: (36 / 812) * MediaQuery.of(context).size.height,
                        text: 'Get Started',
                        buttonColor: AppColors.blue,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pushNamed(context, '/auth');
                        },
                      )
                    : CustomButton(
                        width: (133 / 375) * MediaQuery.of(context).size.width,
                        height: (36 / 812) * MediaQuery.of(context).size.height,
                        text: 'Next',
                        buttonColor: AppColors.blue,
                        textColor: Colors.white,
                        onPressed: () {
                          controller.nextPage(
                              duration: Duration(microseconds: 500),
                              curve: Curves.ease);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
