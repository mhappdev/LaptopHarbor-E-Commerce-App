import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/presentation/views/home/home.dart';
import 'package:laptop_harbor/presentation/views/notification/notification_screen.dart';
import 'package:laptop_harbor/presentation/views/order/orders_history_screen.dart';
import 'package:laptop_harbor/presentation/views/support/chat_page.dart';
import 'package:laptop_harbor/presentation/views/wishlist/wishlist.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Home(),
    Wishlist(),
    OrdersHistoryScreen(),
    NotificationScreen(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Wish List'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Orders History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.support_agent), label: 'Support'),
        ],
      ),
    );
  }
}
