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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white.withOpacity(0.7),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Wish List'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory), label: 'Orders'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.support_agent), label: 'Support'),
            ],
          ),
        ),
      ),
    );
  }
}
