import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color buttonColor;
  final Color textColor;
  final double width;
  final double height;
  final VoidCallback? onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.buttonColor,
    required this.textColor,
    required this.width,
    required this.height,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: buttonColor,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'LeagueSpartan',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
