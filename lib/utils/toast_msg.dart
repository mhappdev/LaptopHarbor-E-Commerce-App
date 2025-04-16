import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:laptop_harbor/core/app_colors.dart';

class ToastMsg {
  static void showToastMsg(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: AppColors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
      webPosition: "center",
      webBgColor: "linear-gradient(to right, #FF0000, #FF0000)",
      webShowClose: true,
    );
  }
}
