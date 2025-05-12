import 'package:flutter/material.dart';

Color getStatusChipColor(String status) {
  switch (status.toLowerCase()) {
    case 'processing':
      return Colors.orange;
    case 'shipped':
      return Colors.blue;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
